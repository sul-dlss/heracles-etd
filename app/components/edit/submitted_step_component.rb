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

    def review_link
      link_to(review_submission_path(@submission.dissertation_id),
              class: ComponentSupport::ButtonSupport.classes(variant: 'primary', classes:)) do
        'Review and submit'
      end
    end

    private

    def classes
      return if all_done?

      'disabled'
    end
  end
end
