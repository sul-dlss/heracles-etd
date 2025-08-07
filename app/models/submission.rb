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
end
