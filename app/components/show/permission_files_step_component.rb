# frozen_string_literal: true

module Show
  # Component for displaying the permission files step in the show view.
  class PermissionFilesStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      @step = SubmissionPresenter::PERMISSION_FILES_STEP
      super()
    end

    attr_reader :step, :submission

    delegate :permission_files, to: :submission
  end
end
