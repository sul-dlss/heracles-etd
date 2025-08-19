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
  end
end
