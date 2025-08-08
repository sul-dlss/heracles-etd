# frozen_string_literal: true

module Edit
  # Component for displaying a progress card showing the steps of a submission
  class ProgressCardComponent < ApplicationComponent
    def step_number_for(step)
      safe_join(
        [
          render(Edit::CharacterCircleComponent.new(character: step, classes: 'me-2 my-2')),
          render(Edit::CharacterCircleComponent.new(character: '✓', variant: :success, classes: 'd-none me-2 my-2'))
        ]
      )
    end
  end
end
