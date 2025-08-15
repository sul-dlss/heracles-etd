# frozen_string_literal: true

# Model for submissions.
class Submission < ApplicationRecord
  before_save :set_derivative_fields

  validates :dissertation_id, presence: true
  validates :druid, presence: true
  validates :etd_type, presence: true, inclusion: { in: %w[Thesis Dissertation] }
  validates :sunetid, presence: true
  validates :title, presence: true

  def first_name
    name.split(', ').last
  end

  def first_last_name
    name.split(', ').reverse.join(' ')
  end

  def copyright_statement
    "© #{submitted_at&.year || Time.zone.today.year} by #{first_last_name}. All rights reserved."
  end

  def set_derivative_fields
    # TODO: Once file uploads are implemented.
    # https://github.com/sul-dlss/heracles-etd/issues/70
    # self.dissertation_uploaded
    # self.supplemental_files_uploaded
    # self.permissions_provided
    # self.permission_files_uploaded
    self.abstract_provided = abstract.present? ? 'true' : 'false'
    self.rights_selected = sulicense
    self.cc_license_selected = cclicense.present? ? 'true' : 'false'
    self.submitted_to_registrar = submitted_at.present? ? 'true' : 'false'
    self.cclicensetype = CreativeCommonsLicense.find(cclicense)&.name
  end
end
