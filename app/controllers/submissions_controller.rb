# frozen_string_literal: true

# Controller for Submissions
class SubmissionsController < ApplicationController
  before_action :set_submission
  before_action :authorize_submission, except: [:edit]

  def show
    # PeopleSoft sends all users to the show route, but if this is the student
    # and the submission hasn't been submitted yet, they should see the edit
    # view.
    redirect_to edit_submission_path(@submission) if allowed_to?(:update?, @submission) && !@submission.submitted?
  end

  def edit
    if @submission.submitted?
      # Allow the redirect to happen, and let the `show` action do its own authorization
      skip_verify_authorized!
      return redirect_to submission_path(@submission)
    end

    authorize! @submission # Authorization has to happen after the redirect check

    # The current user's orcid is provided via shibboleth. It needs to be added
    # to the submission via the edit view.
    @submission.update!(orcid: current_user.orcid) if needs_orcid_update?
  end

  def update # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # All validation happens client-side, so not validating here.
    if params.dig(:submission, :remove_dissertation_file)
      @submission.dissertation_file.purge
    elsif params.dig(:submission, :remove_supplemental_file)
      @submission.supplemental_files.find(params[:submission][:remove_supplemental_file]).delete
    elsif params.dig(:submission, :remove_permission_file)
      @submission.permission_files.find(params[:submission][:remove_permission_file]).delete
    else
      @submission.update!(submission_params)
      # NOTE: This is, we hope, a temporary alert to check whether a Feb. 2026 patch
      #       fixed a bug that cropped up in Oct. 2025 allowing users to submit
      #       ETDs with blank abstracts.
      if @submission.abstract_provided && @submission.abstract.blank?
        Honeybadger.notify(
          '[WARNING] User has collapsed the abstract section with blank abstract! (Check logs & alert service manager)',
          context: {
            submission: @submission,
            params: params
          }
        )
      end
      if @submission.dissertation_file.attached?
        @submission.generate_and_attach_augmented_file!(raise_if_dissertation_missing: true)
      end
    end
    redirect_to edit_submission_path(@submission)
  end

  def review; end

  def submit
    # NOTE: If the following line proves too slow in UAT/prod, use this job-based approach:
    #       PostSubmissionJob.perform_later(submission: @submission)
    SubmissionPoster.call(submission: @submission)
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

  def attach_permission_files
    permission_files = permission_file_params.fetch(:permission_files, [])
    return if permission_files.empty?

    permission_files.each do |file|
      next if file.blank?

      permission_file = PermissionFile.new(submission: @submission)
      permission_file.file.attach(file)
      permission_file.save!
    end
    redirect_to edit_submission_path(@submission)
  end

  def dissertation_file
    return head :not_found unless @submission.dissertation_file.attached?

    send_file ActiveStorageSupport.filepath_for_blob(@submission.dissertation_file),
              type: @submission.dissertation_file.content_type,
              filename: @submission.dissertation_file.filename.to_s,
              disposition: 'attachment'
  end

  # Use the original filename when downloading the augmented file
  def augmented_dissertation_file
    return head :not_found unless @submission.augmented_dissertation_file.attached?

    send_file ActiveStorageSupport.filepath_for_blob(@submission.augmented_dissertation_file),
              type: @submission.augmented_dissertation_file.content_type,
              filename: @submission.dissertation_file.filename.to_s,
              disposition: 'attachment'
  end

  def permission_file
    permission_file = @submission.permission_files.find(params[:file_id])
    send_file ActiveStorageSupport.filepath_for_blob(permission_file.file),
              type: permission_file.content_type,
              filename: permission_file.filename.to_s,
              disposition: 'attachment'
  end

  def supplemental_file
    supplemental_file = @submission.supplemental_files.find(params[:file_id])
    send_file ActiveStorageSupport.filepath_for_blob(supplemental_file.file),
              type: supplemental_file.content_type,
              filename: supplemental_file.filename.to_s,
              disposition: 'attachment'
  end

  private

  def needs_orcid_update?
    return false if @submission.orcid.present?
    return false if current_user.orcid.blank?
    # Note that the sunetid check is redundant given the submission policy, but
    # we are explicit here just in case the policy is changed in the future.
    return false if @submission.sunetid != current_user.sunetid

    true
  end

  # NOTE: The submissions controller allows users to supply either the
  #       dissertation ID *or* the druid to find the correct submission. This is
  #       used often by the service manager.
  def set_submission
    @submission = if params[:id]&.start_with?('druid:')
                    Submission.find_by!(druid: params[:id])
                  else
                    Submission.find_by!(dissertation_id: params[:id])
                  end
  end

  def authorize_submission
    authorize! @submission
  end

  def submission_params
    params.expect(submission: [:abstract, :sulicense, :cclicense, :embargo, :citation_verified,
                               :format_reviewed, :abstract_provided, :rights_selected, :dissertation_file,
                               :dissertation_uploaded, { supplemental_files: [] }, :supplemental_files_uploaded,
                               { permission_files: [] }, :permission_files_uploaded, :permissions_provided,
                               :supplemental_files_provided])
  end

  def permission_file_params
    params.expect(submission: [permission_files: []])
  end

  def supplemental_file_params
    params.expect(submission: [supplemental_files: []])
  end
end
