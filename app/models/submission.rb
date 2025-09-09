# frozen_string_literal: true

# Model for submissions.
class Submission < ApplicationRecord
  include PersonNameConcern
  include SubmissionAdminConcern

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

  # This scope checks for ETDs that have been sent to the ILS since yesterday at 6am and have not yet been updated.
  # It is used to by a cron job to send reminder emails to the catalogers
  scope :ils_records_created_since_yesterday_morning, lambda {
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
    update!(submitted_at: Time.zone.now, readerapproval: nil, last_reader_action_at: nil,
            readercomment: nil, regapproval: nil, last_registrar_action_at: nil, regcomment: nil)

    augmented_dissertation_file.attach(io: File.open(augmented_pdf_path),
                                       filename: File.basename(augmented_pdf_path))
  end

  private

  def augmented_pdf_path
    @augmented_pdf_path ||= SignaturePageService.call(submission: self)
  end
end
