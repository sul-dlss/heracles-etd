# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission, :authorize_submission

  def show; end

  def edit
    add_orcid_to_submission
  end

  # All validation happens client-side, so not validating here.
  def update
    if params.dig(:submission, :remove_dissertation_file)
      @submission.dissertation_file.purge
    elsif params.dig(:submission, :remove_supplemental_file)
      @submission.supplemental_files.find(params[:submission][:remove_supplemental_file]).purge
    else
      @submission.update!(submission_params)
    end
    redirect_to edit_submission_path(@submission)
  end

  def review; end

  def submit
    SubmitToRegistrarService.call(submission: @submission)
    redirect_to submission_path(@submission)
  end

  def reader_review; end

  def preview
    send_file SignaturePagePreviewService.call(submission: @submission), filename: 'preview.pdf',
                                                                         type: 'application/pdf', disposition: 'inline'
  end

  private

  def set_submission
    @submission = Submission.find_by!(dissertation_id: params[:id])
  end

  def authorize_submission
    authorize! @submission
  end

  def submission_params
    params.expect(submission: [:abstract, :sulicense, :cclicense, :embargo, :citation_verified,
                               :format_reviewed, :abstract_provided, :rights_selected, :dissertation_file,
                               :dissertation_uploaded, { supplemental_files: [] }, :supplemental_files_uploaded])
  end

  # The current user's orcid is provided via shibboleth.
  # It needs to be added to the Submission.
  def add_orcid_to_submission
    return if @submission.orcid.present?
    return if current_user.orcid.blank?
    # This is redundant of the policy, but just in case the policy is changed in the future.
    return if @submission.sunetid != current_user.sunetid

    @submission.update!(orcid: current_user.orcid)
  end
end
