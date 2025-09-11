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

    def permissions_provided?
      ActiveModel::Type::Boolean.new.cast(permissions_provided)
    end

    def no_permissions_action
      permission_files.any? ? 'click->submit#warn' : 'submit#submit'
    end

    def done_disabled?
      return false unless permissions_provided?

      permission_files.none?
    end
  end
end
