# frozen_string_literal: true

module Edit
  # Component for displaying a collapsible step on the submitter form.
  class StepComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content
    renders_one :footer_content

    def initialize(step_number:, title:, submission_presenter:, done_field: nil, show: true, data: {}, classes: [],
                   edit_label: 'Edit this section',
                   done_text: 'Click Done to complete this section.', done_label: 'Done', done_data: {},
                   done_disabled: false)
      @step_number = step_number
      @title = title
      @show = show
      @data = data.merge(step_number: step_number)
      @classes = classes
      @edit_label = edit_label
      @done_field = done_field
      @done_text = done_text
      @done_label = done_label
      @done_data = done_data
      @done_disabled = done_disabled
      @submission_presenter = submission_presenter

      super()
    end

    attr_reader :step_number, :title, :done_text, :done_label, :data, :review_field, :form,
                :done_disabled, :edit_label, :done_field, :submission_presenter, :done_data

    def classes
      merge_classes('card card-step mb-3', @classes)
    end

    def show?
      @show
    end

    def character_circle_variant
      show? ? :disabled : :success
    end

    def id
      "step_#{step_number}"
    end
  end
end
