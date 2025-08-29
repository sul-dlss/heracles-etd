# frozen_string_literal: true

# Controller for Supplemental Files
class SupplementalFilesController < ApplicationController
  before_action :set_supplemental_file
  before_action :set_submission

  def update
    # All validation happens client-side, so not validating here.
    authorize! @submission

    @supplemental_file.update!(supplemental_file_params)
    redirect_to edit_submission_path(@submission)
  end

  private

  def set_supplemental_file
    @supplemental_file = SupplementalFile.find(params[:id])
  end

  def set_submission
    @submission = @supplemental_file.submission
  end

  def supplemental_file_params
    params.expect(supplemental_file: [:description])
  end
end
