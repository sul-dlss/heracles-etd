# frozen_string_literal: true

module Shared
  # Component for rendering the progress of a single step on a progress card
  class ProgressCardStepComponent < ApplicationComponent
    def initialize(variant:, label:, aria_label:, character: '', classes: [], step_at: nil)
      @character = variant == :success ? '✓' : character
      @variant = variant
      @classes = classes
      @label = label
      @aria_label = aria_label
      @step_at = step_at

      super()
    end

    attr_reader :character, :variant, :label, :step_at, :aria_label

    def classes
      merge_classes(@classes)
    end
  end
end
