# frozen_string_literal: true

# Form for a Submission.
# This form is used to create or update a Submission model.
class SubmissionForm < ApplicationForm
  attribute :citation_verified, :boolean, default: false
  validates :citation_verified, acceptance: true, on: :submit

  attribute :abstract, :string
  validates :abstract, presence: true, on: :submit

  attribute :dissertation_uploaded, :boolean, default: false
  validates :dissertation_uploaded, acceptance: true, on: :submit

  attribute :permissions_provided, :boolean, default: false
  validates :permissions_provided, acceptance: true, on: :submit

  attribute :rights_selected, :boolean, default: false
  validates :rights_selected, acceptance: true, on: :submit
end
