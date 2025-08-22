# frozen_string_literal: true

module Show
  # Component for displaying the permission files step in the show view.
  class PermissionFilesStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
