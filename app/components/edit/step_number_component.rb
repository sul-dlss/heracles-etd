# frozen_string_literal: true

module Edit
  # Component for displaying a step number in the submission process
  class StepNumberComponent < ApplicationComponent
    def initialize(step_number:, classes: ['me-2 my-2'], variant: :disabled)
      raise ArgumentError unless %i[disabled success blank].include?(variant.to_sym)

      @step_number = step_number
      @classes = classes
      @variant = variant
      super()
    end

    attr_reader :step_number

    def call
      tag.div(
        class: classes
      ) do
        step_number.to_s
      end
    end

    def classes
      merge_classes('step-number', "step-number-#{@variant}", @classes)
    end
  end
end
