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

    def no_permissions_action
      permission_files.any? ? 'click->submit#warn' : 'submit#submit'
    end

    def done_disabled?
      return false unless permissions_provided

      permission_files.none?
    end

    def max_files
      Settings.permission_files.max_files
    end

    def form_data
      {
        controller: 'files',
        files_max_files_value: max_files,
        files_existing_files_value: permission_files.size
      }
    end

    def file_field_data
      {
        controller: 'submit',
        action: 'files#validate submit#submit'
      }
    end
  end
end
