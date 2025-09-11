# frozen_string_literal: true

module Shared
  # Component for displaying a step.
  class StepComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content
    def initialize(title:, step: nil, submission: nil)
      @step = step
      @title = title
      @submission = submission

      super()
    end

    attr_reader :title, :submission, :step

    def step_number
      return if step.blank?

      SubmissionPresenter.step_number(step:)
    end

    def id
      "step-#{step_number}-badge" if step.present?
    end

    def character_circle_id
      "step-#{step_number}-character-circle" if step.present?
    end

    def title_id
      "step-#{step_number || 'none'}-title"
    end

    def aria_labelledby
      [character_circle_id, title_id, id].compact.join(' ')
    end

    def step_done?
      SubmissionPresenter.step_done?(submission:, step:)
    end

    def character_circle_variant
      step_done? ? :success : :disabled
    end

    def badge_component
      return if step.blank?

      step_done? ? Shared::CompletedBadgeComponent.new(id:) : Shared::InProgressBadgeComponent.new(id:)
    end
  end
end
