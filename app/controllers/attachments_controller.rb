# frozen_string_literal: true

# Controller for File Dissertation File Attachments
class AttachmentsController < ApplicationController
  skip_verify_authorized only: :create
  before_action :set_submission, only: :create

  def create
    attach_file
  end

  # def destroy
  #   @submission.dissertation_file.purge if @submission.dissertation_file.attached?
  # end

  private

  def attach_file
    case params[:file_type]
    when 'dissertation_file'
      @submission.dissertation_file.attach(file_blob)
    when 'supplemental_file'
      @submission.supplemental_files.attach(file_blob)
    when 'permissions_file'
      @submission.permissions_files.attach(file_blob)
    end
  end

  def set_submission
    @submission = Submission.find_by!(dissertation_id: params[:submission_id])
  end

  def file_blob
    ActiveStorage::Blob.find_signed(params[:file_id])
  end
end
