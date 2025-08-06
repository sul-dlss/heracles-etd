# frozen_string_literal: true

module Edit
  # Component for displaying a progress card showing the steps of a submission
  class ProgressCardComponent < ApplicationComponent
    def step_number_for(step)
      safe_join(
        [
          render(Edit::StepNumberComponent.new(step_number: step, classes: 'me-2 my-2')),
          render(Edit::StepNumberComponent.new(step_number: '✓', variant: :success, classes: 'd-none me-2 my-2'))
        ]
      )
    end
  end
end
