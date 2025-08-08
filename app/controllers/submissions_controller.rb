# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[edit update show]

  def show; end

  def edit; end

  def update
    # All validation happens client-side, so not validating here.
    # TODO: Add update.
    redirect_to submission_path(@submission.dissertation_id)
  end

  private

  def set_submission
    @submission = Submission.find_by!(dissertation_id: params[:id])
  end
end
