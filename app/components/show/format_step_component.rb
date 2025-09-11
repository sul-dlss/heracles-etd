# frozen_string_literal: true

module Show
  # Component for displaying the format step in the show view.
  class FormatStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      @step = SubmissionPresenter::FORMAT_STEP
      super()
    end

    attr_reader :step, :submission
  end
end
