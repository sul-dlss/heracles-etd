# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission, :authorize_submission

  def show; end

  def edit
    add_orcid_to_submission
  end

  def update # rubocop:disable Metrics/AbcSize
    # All validation happens client-side, so not validating here.
    if params.dig(:submission, :remove_dissertation_file)
      @submission.dissertation_file.purge
    elsif params.dig(:submission, :remove_supplemental_file)
      @submission.supplemental_files.find(params[:submission][:remove_supplemental_file]).delete
    elsif params.dig(:submission, :remove_permission_file)
      @submission.permission_files.find(params[:submission][:remove_permission_file]).purge
      @submission.update!(permissions_provided: nil) if @submission.permission_files.empty?
    else
      @submission.update!(submission_params)
    end
    redirect_to edit_submission_path(@submission)
  end

  def review; end

  def submit
    # TODO: Submit to Registrar.
    @submission.update!(submitted_at: Time.current)
    redirect_to submission_path(@submission)
  end

  def reader_review; end

  def preview
    send_file SignaturePagePreviewService.call(submission: @submission), filename: 'preview.pdf',
                                                                         type: 'application/pdf', disposition: 'inline'
  end

  def attach_supplemental_files
    supplemental_files = supplemental_file_params.fetch(:supplemental_files, [])
    return if supplemental_files.empty?

    supplemental_files.each do |file|
      next if file.blank?

      supplemental_file = SupplementalFile.new(submission: @submission)
      supplemental_file.file.attach(file)
      supplemental_file.save!
    end
    redirect_to edit_submission_path(@submission)
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
                               :dissertation_uploaded, { supplemental_files: [] }, :supplemental_files_uploaded,
                               { permission_files: [] }, :permission_files_uploaded, :permissions_provided])
  end

  def supplemental_file_params
    params.expect(submission: [supplemental_files: []])
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
