# frozen_string_literal: true

module Edit
  # Component for editing submitted step of the submitter form
  class SubmittedStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission

      super()
    end

    attr_reader :submission

    def all_done?
      SubmissionPresenter.all_done?(submission:)
    end

    def step_range_end
      SubmissionPresenter.total_steps - 1
    end
  end
end
