# frozen_string_literal: true

# Model for submissions.
class Submission < ApplicationRecord
  # Active Storage attachments
  has_one_attached :dissertation_file, dependent: :purge_later

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
end
