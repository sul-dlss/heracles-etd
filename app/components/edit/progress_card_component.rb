# frozen_string_literal: true

module Edit
  # Component for displaying a progress card showing the steps of a submission
  class ProgressCardComponent < ApplicationComponent
    def initialize(submission_presenter:)
      @submission_presenter = submission_presenter
      super()
    end

    attr_reader :submission_presenter

    def step_number_for(step)
      if submission_presenter.step_done?(step)
        render(Edit::CharacterCircleComponent.new(character: '✓', variant: :success, classes: 'me-2 my-2'))
      else
        render(Edit::CharacterCircleComponent.new(character: step, classes: 'me-2 my-2'))
      end
    end
  end
end
