# frozen_string_literal: true

# require 'fileutils'

# Job to start accessioning
# This was formerly the OtherMetadataJob
class StartAccessionJob < ApplicationJob
  queue_as :default

  # create metadata for the work item
  def perform(druid)
    @druid = druid

    copy_to_workspace

    updated_dro = refresh_and_add_missing_metadata
    object_client.update(params: updated_dro)
    Sdr::AdministrativeTagCreator.create(submission)

    # Closing the version initiates accessioning
    object_client.version.close

    submission.update!(accessioning_started_at: Time.zone.now)
    # This is the latest point in the ETD's lifecycle within the application
    # that we can create release tags. No need to create release tags before
    # accessioning begins. Ultimately we need the release tags to be created so
    # that the ETD APO's dissemination workflow, releaseWF, can successfully
    # update SearchWorks.
    Sdr::ReleaseTagger.tag(druid:)
  end

  private

  attr_reader :druid

  def workspace_content_directory
    @workspace_content_directory ||= DruidTools::Druid.new(druid, Settings.sdr.local_workspace_root)
                                                      .content_dir(true)
  end

  def submission
    @submission ||= Submission.find_by!(druid:)
  end

  def source_directory
    File.join(Settings.file_uploads_root, druid)
  end

  def refresh_and_add_missing_metadata
    object_client.refresh_descriptive_metadata_from_ils
    object_client
      .find
      .then { |existing_dro| add_access_and_structural(existing_dro) }
      .then { |updated_dro| maybe_add_orcid_type_attribute(updated_dro) }
      .then { |updated_dro| add_doi_identifier(updated_dro) }
      .then { |updated_dro| add_datacite_resource_types(updated_dro) }
  end

  def object_client
    @object_client ||= Dor::Services::Client.object(druid)
  end

  def add_access_and_structural(existing_dro)
    existing_dro.new(
      access: Cocina::DroAccessGenerator.create(submission:),
      structural: {}.tap do |props|
        file_sets = Cocina::FileSetsGenerator.file_sets(submission:, dro_version: existing_dro.version.to_i)
        props[:contains] = file_sets if file_sets.present?
      end
    )
  end

  def add_doi_identifier(dro)
    dro.new(
      identification: dro.identification.new(
        doi: "#{Settings.datacite.prefix}/#{druid.delete_prefix('druid:')}"
      )
    )
  end

  def add_datacite_resource_types(dro)
    dro.new(
      description: dro.description.new(
        form: dro.description.form.push(
          {
            source: {
              value: 'DataCite resource types'
            },
            type: 'resource type',
            value: 'Dissertation'
          }
        )
      )
    )
  end

  def maybe_add_orcid_type_attribute(dro)
    item_hash = dro.to_h

    first_contributor = item_hash.dig(:description, :contributor, 0)
    first_contributor_identifier = first_contributor&.dig(:identifier, 0)
    full_orcid = first_contributor_identifier&.[](:value)
    return dro unless full_orcid&.match?('orcid.org')

    first_contributor_identifier[:value] = full_orcid.split('/').last
    first_contributor_identifier[:type] = 'ORCID'
    first_contributor_identifier[:source] = { uri: 'https://orcid.org' }

    dro.class.new(item_hash)
  end

  def copy_to_workspace
    all_attached_files.each do |attached_file|
      FileUtils.cp ActiveStorageSupport.filepath_for_blob(attached_file.blob),
                   File.join(workspace_content_directory, attached_file.filename.to_s)
    end
  end

  def all_attached_files
    [submission.dissertation_file,
     submission.augmented_dissertation_file] + submission.supplemental_files + submission.permission_files
  end
end
