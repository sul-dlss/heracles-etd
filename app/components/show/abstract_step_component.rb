# frozen_string_literal: true

module Show
  # Component for displaying the abstract step in the show view.
  class AbstractStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      @step = SubmissionPresenter::ABSTRACT_STEP
      super()
    end

    attr_reader :step, :submission
  end
end
