# frozen_string_literal: true

module Edit
  # Component for displaying a collapsible item on the submitter form.
  class CollapseItemComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content
    renders_one :footer_content
    def initialize(step_number:, title:, edit_variant: :edit, data: {}, classes: [],
                   done_text: 'Click Done to complete this section.', done_label: 'Done', done_data: {})
      @step_number = step_number
      @title = title
      @edit_variant = edit_variant.to_sym
      @data = data.merge(step_number: step_number)
      @classes = classes
      @done_text = done_text
      @done_label = done_label
      @done_data = done_data

      raise ArgumentError, 'Invalid edit variant' unless %i[edit review].include?(@edit_variant)

      super()
    end

    attr_reader :step_number, :title, :edit_variant, :done_text, :done_label, :data

    def editing_label
      edit_variant == :edit ? 'Editing' : 'Reviewing'
    end

    def edit_label
      edit_variant == :edit ? 'Edit this section' : 'Undo your confirmation'
    end

    def collapse_id
      "collapse_#{step_number}"
    end

    def classes
      merge_classes('collapse-item card mb-3', @classes)
    end

    def done_data
      @done_data.merge(bs_toggle: 'collapse', bs_target: "##{collapse_id}")
    end
  end
end
