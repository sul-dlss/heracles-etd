# frozen_string_literal: true

module Edit
  # Component for editing the permission files upload step of the submitter form
  class PermissionFilesStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :permission_files, to: :submission

    def edit_focus_id
      # focus on the file upload field
      helpers.submission_form_field_id(submission, :permission_files)
    end
  end
end
