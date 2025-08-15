# frozen_string_literal: true

module Shared
  # Component for displaying a step.
  class StepComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content
    def initialize(title:, step_number: nil, data: {}, classes: [])
      @step_number = step_number
      @title = title
      @data = data
      @classes = classes

      super()
    end

    attr_reader :step_number, :title, :data

    def classes
      merge_classes('card border-0 mb-3', @classes)
    end
  end
end
