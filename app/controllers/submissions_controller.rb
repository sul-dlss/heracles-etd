# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission

  def show; end

  def edit; end

  def update
    # All validation happens client-side, so not validating here.
    @submission.update!(submission_params)
    redirect_to review_submission_path(@submission.dissertation_id)
  end

  def review
  end

  def submit
    # TODO: Submit to Registrar.
    redirect_to submission_path(@submission.dissertation_id)
  end

  private

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
