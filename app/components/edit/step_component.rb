# frozen_string_literal: true

module Edit
  # Component for displaying a collapsible step on the submitter form.
  class StepComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content
    renders_one :footer_content

    def initialize(step:, title:, submission:, data: {}, classes: [],
                   edit_label: 'Edit this section',
                   done_text: 'Click Done to complete this section.', done_label: 'Done', done_data: {},
                   done_disabled: false)
      @step = step
      @title = title
      @submission = submission
      @data = data.merge(step_number: step_number)
      @classes = classes
      @edit_label = edit_label
      @done_text = done_text
      @done_label = done_label
      @done_data = done_data
      @done_disabled = done_disabled

      super()
    end

    attr_reader :step, :title, :done_text, :done_label, :data, :form,
                :done_disabled, :edit_label, :done_data, :submission

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

    def badge_component
      show? ? Edit::InProgressBadgeComponent : Edit::CompletedBadgeComponent
    end
  end
end
