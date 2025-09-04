# frozen_string_literal: true

module Shared
  # Component for rendering the progress of a single step on a progress card
  class ProgressCardStepComponent < ApplicationComponent
    def initialize(variant:, label:, character: '', classes: [], step_at: nil, comment: nil)
      @character = variant == :success ? '✓' : character
      @variant = variant
      @classes = classes
      @label = label
      @step_at = step_at
      @comment = comment

      super()
    end

    attr_reader :character, :comment, :variant, :label, :step_at

    def classes
      merge_classes(@classes)
    end
  end
end
