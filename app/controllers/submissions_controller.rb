# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission

  def show
    authorize! @submission
  end

  def edit
    authorize! @submission
  end

  def update
    # All validation happens client-side, so not validating here.
    authorize! @submission

    @submission.update!(submission_params)
    redirect_to edit_submission_path(@submission.dissertation_id)
  end

  def review
    authorize! @submission

    render layout: false
  end

  def submit
    authorize! @submission
    # TODO: Submit to Registrar.
    @submission.update!(submitted_at: Time.current)
    redirect_to submission_path(@submission.dissertation_id)
  end

  def reader_review
    authorize! @submission
  end

  private

  def set_submission
    @submission = Submission.find_by!(dissertation_id: params[:id])
  end

  def submission_params
    params.expect(submission: %i[abstract sulicense cclicense embargo citation_verified
                                 format_reviewed abstract_provided rights_selected ])
  end
end
