# frozen_string_literal: true

module Show
  # Component for displaying a section.
  class SectionCardComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content
    def initialize(step_number:, title:, data: {}, classes: [])
      @step_number = step_number
      @title = title
      @data = data.merge(step_number: step_number)
      @classes = classes

      super()
    end

    attr_reader :step_number, :title, :data

    def classes
      merge_classes('card border-0 mb-3', @classes)
    end
  end
end
