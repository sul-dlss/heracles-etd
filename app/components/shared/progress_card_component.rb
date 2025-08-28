# frozen_string_literal: true

module Shared
  # Component for displaying a progress card showing the steps of a submission
  class ProgressCardComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :submitted_at, to: :submission

    def step_number_for(step)
      if SubmissionPresenter.step_done?(step:, submission:)
        render(Edit::CharacterCircleComponent.new(character: '✓', variant: :success, classes: 'me-2 my-2'))
      else
        character = SubmissionPresenter.step_number(step:)
        render(Edit::CharacterCircleComponent.new(character:, classes: 'me-2 my-2'))
      end
    end

    def progress_card_step_component(step:, label:, step_at: nil)
      step_number = SubmissionPresenter.step_number(step:)
      params = if SubmissionPresenter.step_done?(step:, submission:)
                 { character: '✓', variant: :success }
               else
                 { character: step_number, variant: :disabled }
               end
      Shared::ProgressCardStepComponent.new(**params, label:, step_at:)
    end

    def aria_label_for_step(step:, label:)
      step_number = SubmissionPresenter.step_number(step:)
      status = SubmissionPresenter.step_done?(step:, submission:) ? 'Completed' : 'In progress'

      ["Step #{step_number}", label, status].join(', ')
    end
  end
end
