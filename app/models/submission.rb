# frozen_string_literal: true

# Model for submissions.
class Submission < ApplicationRecord
  include PersonNameConcern
  include SubmissionAdminConcern

  DOI_SERVICE_ENABLED_DATE = Date.parse('2025-09-18').freeze

  # Fields transferred from PeopleSoft
  # - dissertation_id
  # - title
  # - etd_type (from type field)
  # - ps_career (from career)
  # - department (from program)
  # - degree
  # - major (from plan)
  # - degree
  # - ps_subplan
  # - provost (from vpname)
  # - name
  # - sub
  # - readerapproval
  # - readercomment
  # - readeractiondttm
  # - regapproval
  # - regcomment
  # - regactiondttm
  # - documentaccess
  # - univid
  # - sunetid
  # - degreeconfyr
  # - schoolname

  # Values provided by student
  # - abstract
  # - containscopyright (boolean; used in Hydra but not Heracles)
  # - sulicense (boolean for checkbox; currently has "true" or nil)
  # - cclicense (creative commons license)
  # - embargo

  # Derivative fields (set in Submission based on other fields)
  # - cclicensetype (set from cclicense)
  # - submitted_to_registrar (boolean; set if submitted_at present)

  # UI section flags (boolean)
  # - citation_verified
  # - abstract_provided
  # - dissertation_uploaded
  # - supplemental_files_uploaded
  # - permission_files_uploaded
  # - rights_selected
  # - format_reviewed

  # Other UI flags (boolean)
  # - permissions_provided (toggle indicating that permission files will be provided)
  # - supplemental_files_provided (toggle indicating that supplemental files will be provided)

  # Dates
  # - submitted_at (set by SubmissionPoster service)
  # - last_registrar_action_at
  # - last_reader_action_at
  # - ils_record_created_at (set by CreateStubMarcRecordJob)
  # - ils_record_updated_at (unclear; previously set by CatalogStatusJob)
  # - accessioning_started_at (set by StartAccessionJob)

  # Other
  # - folio_instance_hrid (set by CreateStubMarcRecordJob)
  # - orcid (set by SubmissionsController)

  before_save :set_derivative_fields

  has_many :readers, -> { order(position: :asc) }, dependent: :destroy, inverse_of: :submission

  # Active Storage attachments
  has_one_attached :dissertation_file, dependent: :purge_later
  has_one_attached :augmented_dissertation_file, dependent: :purge_later

  has_many :supplemental_files, dependent: :destroy, inverse_of: :submission
  accepts_nested_attributes_for :supplemental_files, allow_destroy: true

  has_many :permission_files, dependent: :destroy, inverse_of: :submission
  accepts_nested_attributes_for :permission_files, allow_destroy: true

  validates :dissertation_id, presence: true
  validates :druid, presence: true
  validates :etd_type, presence: true, inclusion: { in: %w[Thesis Dissertation] }
  validates :sunetid, presence: true
  validates :title, presence: true
  validates :embargo, inclusion: { in: [nil, '1 year', '2 years', 'immediately', '6 months'] }

  # This scope checks for ETDs that have been sent to the ILS since yesterday at 6am and have not yet been updated.
  # It is used to by a cron job to send reminder emails to the catalogers
  scope :ils_records_created_since_yesterday_morning, -> {
    at_ils_loaded.where('ils_record_created_at > ?', Time.now.yesterday.change(hour: 6).utc)
  }

  # Defining `#to_param` this makes the diss ID the default param to use when
  # building a path or URL for a submission. E.g., `submission_path(submission)`
  # will now route to `/submissions/000001234` (the diss ID) instead of
  # `/submissions/357` (the DB ID).
  def to_param
    dissertation_id
  end

  def to_honeybadger_context
    {
      dissertation_id:,
      sunetid:,
      druid:
    }
  end

  # These are the values needed to send to PeopleSoft when submitting a submission.
  def to_peoplesoft_hash
    {
      dissertation_id:,
      title:,
      type: etd_type,
      timestamp: submitted_at,
      purl:
    }
  end

  def copyright_statement
    "© #{submitted_at&.year || Time.zone.today.year} by #{first_last_name}. All rights reserved."
  end

  def doi
    # On 2025-09-18, the ETD application began registering DOIs for every
    # submission, and we want to display the DOI so users have a record before
    # it is minted. Any submissions created before that date should be
    # considered not to have DOIs. We also guard against returning a DOI for
    # in-memory submissions, which do not yet have a created_at value to compare
    # against, as this can occur in the test suite.
    return if created_at.blank? || created_at < DOI_SERVICE_ENABLED_DATE

    "#{Settings.datacite.prefix}/#{druid.delete_prefix('druid:')}"
  end

  def purl
    "#{Settings.purl.url}/#{druid.delete_prefix('druid:')}"
  end

  def thesis?
    etd_type == 'Thesis'
  end

  def submitted?
    submitted_at.present?
  end

  def ready_for_cataloging?
    /approved/i.match?(regapproval) && /approved/i.match?(readerapproval)
  end

  def creative_commons_license
    CreativeCommonsLicense.find(cclicense)
  end

  def embargo_release_date
    Embargo.embargo_date(start_date: submitted_at, id: embargo)
  end

  def set_derivative_fields
    # TODO: Once file uploads are implemented.
    # https://github.com/sul-dlss/heracles-etd/issues/70
    self.cc_license_selected = cclicense.present? ? 'true' : 'false'
    self.submitted_to_registrar = submitted_at.present? ? 'true' : 'false'
    self.cclicensetype = CreativeCommonsLicense.find(cclicense)&.name
    self.permissions_provided = nil unless permissions_provided == 'true'
    self.supplemental_files_provided = nil unless supplemental_files_provided == 'true'
  end

  def prepare_to_submit!
    Submission.transaction do
      update!(submitted_at: Time.zone.now, readerapproval: nil, last_reader_action_at: nil,
              readercomment: nil, regapproval: nil, last_registrar_action_at: nil, regcomment: nil)
      generate_and_attach_augmented_file!(raise_if_dissertation_missing: true)
    end
  end

  def generate_and_attach_augmented_file!(raise_if_dissertation_missing: false)
    augmented_dissertation_file.attach(io: File.open(augmented_pdf_path), filename: File.basename(augmented_pdf_path))
  rescue TypeError => e
    # Student has not yet uploaded their dissertation file.
    raise e if raise_if_dissertation_missing
  end

  private

  def augmented_pdf_path
    @augmented_pdf_path ||= SignaturePageService.call(submission: self)
  end
end
