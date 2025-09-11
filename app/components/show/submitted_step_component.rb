# frozen_string_literal: true

module Show
  # Component for displaying submitted step in the show view.
  class SubmittedStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      @step = SubmissionPresenter::SUBMITTED_STEP
      super()
    end

    attr_reader :step, :submission

    delegate :submitted_at, to: :submission
  end
end
