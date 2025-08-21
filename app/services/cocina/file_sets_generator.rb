# frozen_string_literal: true

module Cocina
  # Service for generating Cocina file sets for an ETD
  class FileSetsGenerator
    # @param [Integer] version of DRO object
    def self.file_sets(submission:, dro_version:)
      generator = new(submission: submission, dro_version: dro_version)
      [
        generator.dissertation_file_set,
        generator.augmented_dissertation_file_set,
        generator.supplemental_file_sets,
        generator.permission_file_sets
      ].flatten.compact
    end

    def initialize(submission:, dro_version:)
      @submission = submission
      @dro_version = dro_version
      @resource_index = 0
    end

    def dissertation_file_set
      {
        type: Cocina::Models::FileSetType.file,
        label: 'Body of dissertation (as submitted)',
        externalIdentifier: file_set_external_identifier,
        version: dro_version,
        structural: {
          contains: [file_props(submission.dissertation_file, publish_and_shelve: false)]
        }
      }
    end

    def augmented_dissertation_file_set
      {
        type: Cocina::Models::FileSetType.file,
        label: 'Body of dissertation',
        externalIdentifier: file_set_external_identifier,
        version: dro_version,
        structural: {
          contains: [file_props(submission.augmented_dissertation_file, publish_and_shelve: true)]
        }
      }
    end

    def supplemental_file_sets
      submission.supplemental_files.map do |suppl_file|
        {
          type: Cocina::Models::FileSetType.file,
          label: 'supplemental file',
          externalIdentifier: file_set_external_identifier,
          version: dro_version,
          structural: {
            contains: [file_props(suppl_file, publish_and_shelve: true)]
          }
        }
      end
    end

    def permission_file_sets
      submission.permission_files.map do |perm_file|
        {
          type: Cocina::Models::FileSetType.file,
          label: 'permission file',
          externalIdentifier: file_set_external_identifier,
          version: dro_version,
          structural: {
            contains: [file_props(perm_file, publish_and_shelve: false)]
          }
        }
      end
    end

    private

    attr_reader :submission, :dro_version
    attr_accessor :resource_index

    def bare_druid
      submission.druid.delete_prefix('druid:')
    end

    def file_props(uploaded_file, publish_and_shelve:)
      {
        type: Cocina::Models::ObjectType.file,
        externalIdentifier: file_external_identifier,
        label: uploaded_file.filename.to_s,
        filename: uploaded_file.filename.to_s,
        version: dro_version,
        hasMessageDigests: digests(uploaded_file),
        access: file_access,
        administrative: {
          publish: publish_and_shelve,
          shelve: publish_and_shelve,
          sdrPreserve: true
        },
        # optional properties
        size: uploaded_file.byte_size,
        hasMimeType: uploaded_file.content_type
      }
    end

    def digests(uploaded_file)
      path = ActiveStorageSupport.filepath_for_blob(uploaded_file.blob)
      [
        {
          type: 'sha1',
          digest: Digest::SHA1.file(path).hexdigest
        },
        {
          type: 'md5',
          digest: Digest::MD5.file(path).hexdigest
        }
      ]
    end

    # Note, this has a side effect in that it increments the resource index each time it is called
    def file_set_external_identifier
      "#{bare_druid}_#{@resource_index += 1}"
    end

    def file_external_identifier
      "https://cocina.sul.stanford.edu/file/#{bare_druid}-#{@resource_index}/#{SecureRandom.uuid}"
    end

    # returns the DRO :view and :download props
    def file_access
      @file_access ||= Cocina::DroAccessGenerator.create(submission:).slice(:view, :download)
    end
  end
end
