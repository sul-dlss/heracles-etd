# frozen_string_literal: true

module ReaderReview
  # Component for displaying the rights step in the reader review view.
  class RightsStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
