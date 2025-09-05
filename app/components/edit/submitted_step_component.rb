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
      return tag.span('Review and submit', class: 'btn btn-primary disabled') unless all_done?

      link_to(review_submission_path(@submission),
              class: ComponentSupport::ButtonSupport.classes(variant: 'primary')) do
        'Review and submit'
      end
    end
  end
end
