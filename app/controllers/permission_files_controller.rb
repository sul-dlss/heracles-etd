# frozen_string_literal: true

# Controller for Permission Files
class PermissionFilesController < ApplicationController
  before_action :set_permission_file
  before_action :set_submission

  def update
    # All validation happens client-side, so not validating here.
    authorize! @submission

    @permission_file.update!(permission_file_params)
    redirect_to edit_submission_path(@submission.dissertation_id)
  end

  private

  def set_permission_file
    @permission_file = PermissionFile.find(params[:id])
  end

  def set_submission
    @submission = @permission_file.submission
  end

  def permission_file_params
    params.expect(permission_file: [:description])
  end
end
