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

  has_many_attached :permission_files, dependent: :purge_later

  validates :dissertation_id, presence: true
  validates :druid, presence: true
  validates :etd_type, presence: true, inclusion: { in: %w[Thesis Dissertation] }
  validates :sunetid, presence: true
  validates :title, presence: true

  # Defining `#to_param` this makes the diss ID the default param to use when
  # building a path or URL for a submission. E.g., `submission_path(submission)`
  # will now route to `/submissions/000001234` (the diss ID) instead of
  # `/submissions/357` (the DB ID).
  def to_param
    dissertation_id
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
  end
end
