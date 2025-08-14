# frozen_string_literal: true

# Model for submissions.
class Submission < ApplicationRecord
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
end
