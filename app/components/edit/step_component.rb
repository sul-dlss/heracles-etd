# frozen_string_literal: true

module Edit
  # Component for displaying a collapsible step on the submitter form.
  class StepComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content
    renders_one :footer_content

    def initialize(step_number:, title:, show: true, data: {}, classes: [],
                   edit_label: 'Edit this section', edit_data: {},
                   done_text: 'Click Done to complete this section.', done_label: 'Done', done_data: {},
                   done_disabled: false)
      @step_number = step_number
      @title = title
      @show = show
      @data = data.merge(step_number: step_number)
      @classes = classes
      @edit_label = edit_label
      @edit_data = edit_data
      @done_text = done_text
      @done_label = done_label
      @done_data = done_data
      @done_disabled = done_disabled

      super()
    end

    attr_reader :step_number, :title, :done_text, :done_label, :data, :review_field, :form,
                :done_disabled, :edit_label

    def collapse_id
      "collapse_#{step_number}"
    end

    def classes
      merge_classes('collapse-item card mb-3', @classes)
    end

    def collapse_classes
      merge_classes('collapse collapse-step', show? ? 'show' : nil)
    end

    def edit_data
      # reverse merging so that action is not overridden.
      @edit_data.reverse_merge(
        bs_target: "##{collapse_id}",
        action: 'submit-form#toggle'
      )
    end

    def edit_classes
      merge_classes('btn-edit text-nowrap', show? ? 'd-none' : nil)
    end

    def done_data
      @done_data.merge(bs_target: "##{collapse_id}",
                       action: merge_actions(@done_data[:action], 'submit-form#toggleAndSubmit'))
    end

    def show?
      @show
    end

    def in_progress_badge_classes
      merge_classes('ms-3 mt-1', show? ? nil : 'd-none')
    end

    def completed_badge_classes
      merge_classes('ms-3 mt-1', show? ? 'd-none' : nil)
    end

    def character_circle_variant
      show? ? :disabled : :success
    end
  end
end
