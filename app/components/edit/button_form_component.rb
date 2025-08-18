# frozen_string_literal: true

module Edit
  # Component for rendering a submit button wrapped in a form.
  class ButtonFormComponent < ApplicationComponent
    def initialize(submission:, field:, value:, label: nil, classes: [], **options)
      @label = label
      @submission = submission
      @field = field
      @value = value
      @classes = classes
      @options = options
      super()
    end

    attr_reader :submission, :field, :value, :label, :classes, :options
  end
end
