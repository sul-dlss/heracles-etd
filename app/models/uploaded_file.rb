# frozen_string_literal: true

# Model for uploaded files, which can be associated with submissions
class UploadedFile < ApplicationRecord
  has_many :attachments, dependent: :destroy
  has_many :submissions, through: :attachments

  def parent
    submissions.first
  end

  delegate :druid, to: :parent

  def file_path
    File.join(Settings.file_uploads_root, druid, file_name)
  end
end
