# frozen_string_literal: true

# Model for submissions.
class Submission < ApplicationRecord
  has_one_attached :dissertation_file, dependent: :purge_later
  has_many_attached :supplemental_files, dependent: :purge_later
  has_many_attached :permission_files, dependent: :purge_later

  validates :dissertation_id, presence: true
  validates :druid, presence: true
  validates :etd_type, presence: true, inclusion: { in: %w[Thesis Dissertation] }
  validates :sunetid, presence: true
  validates :title, presence: true

  def first_name
    name.split(', ').last
  end
end
