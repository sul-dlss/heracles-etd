# frozen_string_literal: true

module Shared
  # Component for displaying a step.
  class StepComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content
    def initialize(title:, step: nil, data: {}, classes: [])
      @step = step
      @title = title
      @data = data
      @classes = classes

      super()
    end

    attr_reader :title, :data

    def step_number
      return if @step.blank?

      SubmissionPresenter.step_number(step: @step)
    end

    def classes
      merge_classes('card mb-3', @classes)
    end

    def badge_id
      "step-#{step_number}-badge" if @step.present?
    end

    def character_circle_id
      "step-#{step_number}-character-circle" if @step.present?
    end

    def title_id
      "step-#{step_number || 'none'}-title"
    end

    def aria_labelledby
      [character_circle_id, title_id, badge_id].compact.join(' ')
    end
  end
end
