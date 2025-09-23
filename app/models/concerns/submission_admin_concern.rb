# frozen_string_literal: true

# Concern for supporting admin for submissions.
# This is intended to encapsulate all ActiveAdmin-related logic for submissions.
module SubmissionAdminConcern
  extend ActiveSupport::Concern

  REQUIRED_ETD_WORKFLOW_STEPS = %i[citation_verified abstract_provided
                                   dissertation_uploaded rights_selected].freeze

  included do
    scope :has_submitted_at, -> { where.not(submitted_at: nil) }
    scope :not_reader_approved, -> { where.not(readerapproval: 'Approved').or(where(readerapproval: nil)) }
    scope :reader_approved, -> { where(readerapproval: 'Approved') }
    scope :not_registrar_approved, -> { where.not(regapproval: 'Approved').or(where(regapproval: nil)) }
    scope :registrar_approved, -> { where(regapproval: 'Approved') }
    scope :no_catalog_record_id, -> { where(folio_instance_hrid: [nil, '']) }
    scope :has_catalog_record_id, -> { where.not(folio_instance_hrid: [nil, '']) }
    scope :ils_record_not_updated, -> { where(ils_record_updated_at: nil) }
    scope :ils_record_updated, -> { where.not(ils_record_updated_at: nil) }
    scope :accessioning_not_started, -> { where(accessioning_started_at: nil) }
    scope :accessioning_started, -> { where.not(accessioning_started_at: nil) }

    scope :at_registered, -> { where(submitted_at: nil) }
    scope :at_submitted, -> { has_submitted_at.not_reader_approved }
    scope :at_reader_approved, -> { reader_approved.not_registrar_approved.has_submitted_at }
    scope :at_registrar_approved, -> { registrar_approved.no_catalog_record_id.reader_approved.has_submitted_at }
    scope :at_ils_loaded, -> {
      has_catalog_record_id.ils_record_not_updated.registrar_approved.reader_approved.has_submitted_at
    }
    scope :at_ils_cataloged, -> {
      ils_record_updated.accessioning_not_started.has_catalog_record_id.registrar_approved
                        .reader_approved.has_submitted_at
    }
    scope :at_accessioning_started, -> {
      accessioning_started.ils_record_updated.has_catalog_record_id.registrar_approved.reader_approved.has_submitted_at
    }
  end

  class_methods do
    # associations that are searchable via activeadmin
    def ransackable_associations(_auth_object = nil)
      %w[readers]
    end

    # attributes that are searchable via activeadmin
    def ransackable_attributes(_auth_object = nil)
      %w[abstract abstract_provided accessioning_started_at
         cclicense cclicensetype citation_verified
         created_at degree degreeconfyr department dissertation_id dissertation_uploaded
         documentaccess druid embargo etd_type folio_instance_hrid
         format_reviewed id ils_record_created_at ils_record_updated_at last_reader_action_at
         last_registrar_action_at major name permission_files_uploaded permissions_provided
         prefix provost ps_career ps_subplan readeractiondttm
         readerapproval readercomment regactiondttm regapproval regcomment rights_selected
         schoolname sub submitted_at submitted_to_registrar suffix sulicense
         sunetid supplemental_files_uploaded term title univid updated_at]
    end
  end

  def bare_druid
    druid.delete_prefix('druid:')
  end

  def augmented_dissertation_file_name
    return unless augmented_dissertation_file.attached?

    augmented_dissertation_file.filename.to_s
  end

  def all_required_steps_complete?
    REQUIRED_ETD_WORKFLOW_STEPS.all? { |step| self[step] == true }
  end
end
