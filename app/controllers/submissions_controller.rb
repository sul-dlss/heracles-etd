# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[edit update show remove_dissertation_file]

  def show
    authorize! @submission
  end

  def edit
    authorize! @submission
  end

  def update
    # All validation happens client-side, so not validating here.
    authorize! @submission

    attach_dissertation
    @submission.update!(submission_params)

    redirect_to submission_path(@submission.dissertation_id)
  end

  def remove_dissertation_file
    @submission.dissertation_file.purge if @submission.dissertation_file.attached?

    redirect_to edit_submission_path(@submission.dissertation_id)
  end

  private

  def attach_dissertation
    return unless params[:submission] && params[:submission][:dissertation_file].present?

    @submission.dissertation_file.attach(params[:submission][:dissertation_file])
  end

  def set_submission
    @submission = Submission.find_by!(dissertation_id: params[:id])
  end

  def submission_params
    params.expect(submission: %i[abstract sulicense cclicense embargo]).merge(cclicensetype:)
  end

  def cclicensetype
    CreativeCommonsLicense.find(params.dig(:submission, :cclicense)).name
  end
end
