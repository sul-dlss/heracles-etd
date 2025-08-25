# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission

  def show
    authorize! @submission
  end

  def edit
    authorize! @submission

    add_orcid_to_submission
  end

  def update # rubocop:disable Metrics/AbcSize
    # All validation happens client-side, so not validating here.
    authorize! @submission

    if params.dig(:submission, :remove_dissertation_file)
      @submission.dissertation_file.purge
    elsif params.dig(:submission, :remove_supplemental_file)
      @submission.supplemental_files.find(params[:submission][:remove_supplemental_file]).purge
    elsif params.dig(:submission, :remove_permission_file)
      @submission.permission_files.find(params[:submission][:remove_permission_file]).purge
    else
      @submission.update!(submission_params)
    end
    redirect_to edit_submission_path(@submission.dissertation_id)
  end

  def review
    authorize! @submission
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

  def preview
    authorize! @submission

    send_file SignaturePagePreviewService.call(submission: @submission), filename: 'preview.pdf',
                                                                         type: 'application/pdf', disposition: 'inline'
  end

  private

  def set_submission
    @submission = Submission.find_by!(dissertation_id: params[:id])
  end

  def submission_params
    params.expect(submission: [:abstract, :sulicense, :cclicense, :embargo, :citation_verified,
                               :format_reviewed, :abstract_provided, :rights_selected, :dissertation_file,
                               :dissertation_uploaded, { supplemental_files: [] }, :supplemental_files_uploaded,
                               { permission_files: [] }, :permission_files_uploaded, :permissions_provided])
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
