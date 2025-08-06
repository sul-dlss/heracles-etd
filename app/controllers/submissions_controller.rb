# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[edit update]

  # GET /submissions/:id/edit
  def edit
    # The edit action will render the edit view for the submission
  end

  def update
    redirect_to edit_submission_path(@submission)
  end

  private

  def set_submission
    @submission = Submission.new(
      name: 'Chan, Yi Hsuan',
      dissertation_id: '0000111829',
      schoolname: 'School of Engineering',
      department: 'Bioengineering',
      degree: 'Ph.D.',
      major: 'Bioengineering',
      degreeconfyr: '2023',
      title: 'High-throughput Genomics for Understanding and Engineering Immune Cell Memory'
    )
  end
end
