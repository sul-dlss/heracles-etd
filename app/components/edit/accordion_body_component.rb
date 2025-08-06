# frozen_string_literal: true

module Edit
  # Component for the body of an accordion item
  class AccordionBodyComponent < ApplicationComponent
    renders_one :body_content
    renders_one :footer_content

    def initialize(step_number:)
      @step_number = step_number
      super()
    end

    attr_reader :step_number

    def collapse_id
      "collapse_#{step_number}"
    end
  end
end
