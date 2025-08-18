# frozen_string_literal: true

module Show
  # Component for displaying the rights step in the show view.
  class RightsStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
