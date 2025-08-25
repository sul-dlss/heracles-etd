# frozen_string_literal: true

module Edit
  # Component for editing the permission files upload step of the submitter form
  class PermissionFilesStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :permissions_provided, :permission_files, to: :submission

    def edit_focus_id
      # focus on the file upload field
      helpers.submission_form_field_id(submission, :permission_files)
    end

    def permissions_provided?
      ActiveModel::Type::Boolean.new.cast(permissions_provided)
    end

    def done_disabled?
      return false unless permissions_provided?

      !permission_files.attached?
    end
  end
end
