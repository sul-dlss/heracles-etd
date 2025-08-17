# frozen_string_literal: true

module Show
  # Component for displaying submitted step in the show view.
  class SubmittedStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission

      super()
    end

    attr_reader :submission

    delegate :submitted_at, to: :submission
  end
end
