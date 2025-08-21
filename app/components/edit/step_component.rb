# frozen_string_literal: true

module Edit
  # Component for displaying a collapsible step on the submitter form.
  class StepComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content
    renders_one :footer_content

    def initialize(step:, title:, submission:, data: {}, classes: [],
                   edit_label: 'Edit this section',
                   edit_focus_id: nil,
                   done_text: 'Click Done to complete this section.', done_label: 'Done', done_data: {},
                   done_disabled: false)
      @step = step
      @title = title
      @submission = submission
      @data = data.merge(step_number: step_number)
      @classes = classes
      @edit_label = edit_label
      # The id of the element that gets focus after the edit button is clicked.
      @edit_focus_id = edit_focus_id || done_id # Default to done button.
      @done_text = done_text
      @done_label = done_label
      @done_data = add_focus(done_data)
      @done_disabled = done_disabled

      super()
    end

    attr_reader :step, :title, :done_text, :done_label, :data, :form,
                :done_disabled, :edit_label, :done_data, :submission, :edit_focus_id

    def classes
      merge_classes('card card-step mb-3', @classes)
    end

    def show?
      !SubmissionPresenter.step_done?(step:, submission:)
    end

    def step_number
      SubmissionPresenter.step_number(step:)
    end

    def done_field
      SubmissionPresenter.step_field(step:)
    end

    def character_circle_variant
      show? ? :disabled : :success
    end

    def id
      "step-#{step_number}"
    end

    def aria_label
      "#{step_number} #{title} #{show? ? 'in progress' : 'completed'}"
    end

    def edit_id
      "step-#{step_number}-edit"
    end

    def done_id
      SubmissionPresenter.done_id(step:)
    end

    def badge_component
      show? ? Edit::InProgressBadgeComponent : Edit::CompletedBadgeComponent
    end

    def edit_data
      {
        action: 'click->focus#saveFocus',
        focus_id_param: edit_focus_id
      }
    end

    def add_focus(data)
      # This sets so that after the form is submitted, the focus will be set to the edit button.
      data[:action] = merge_actions(data[:action], 'click->focus#saveFocus')
      data[:focus_id_param] = edit_id
      data
    end
  end
end
