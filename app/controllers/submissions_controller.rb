# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[edit update show]

  def show
    authorize! @submission
  end

  def edit
    authorize! @submission

    @submission_presenter = SubmissionPresenter.new(submission: @submission)
  end

  def update
    # All validation happens client-side, so not validating here.
    authorize! @submission

    @submission.update!(submission_params)
    if params[:commit] == 'Review and submit'
      # TODO: Implement review and submit.
      redirect_to submission_path(@submission.dissertation_id)
    else
      redirect_to edit_submission_path(@submission.dissertation_id)
    end
  end

  private

  def set_submission
    @submission = Submission.find_by!(dissertation_id: params[:id])
  end

  def submission_params
    params.expect(submission: %i[abstract sulicense cclicense embargo citation_verified
                                 format_reviewed]).merge(cclicensetype:)
  end

  def cclicensetype
    CreativeCommonsLicense.find(params.dig(:submission, :cclicense))&.name
  end
end
