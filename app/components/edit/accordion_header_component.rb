# frozen_string_literal: true

module Edit
  # Component for the header of an accordion item
  class AccordionHeaderComponent < ApplicationComponent
    renders_one :help_content

    def initialize(step_number:, title:, editing_label:, edit_label:)
      @step_number = step_number
      @title = title
      @editing_label = editing_label
      @edit_label = edit_label
      super()
    end

    attr_reader :step_number, :title, :editing_label, :edit_label

    def collapse_id
      "collapse_#{step_number}"
    end
  end
end
