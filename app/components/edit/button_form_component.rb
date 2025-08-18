# frozen_string_literal: true

module Edit
  # Component for rendering a submit button wrapped in a form.
  class ButtonFormComponent < ApplicationComponent
    def initialize(submission_presenter:, field:, value:, label: nil, classes: [], **options)
      @label = label
      @submission_presenter = submission_presenter
      @field = field
      @value = value
      @classes = classes
      @options = options
      super()
    end

    attr_reader :submission_presenter, :field, :value, :label, :classes, :options
  end
end
