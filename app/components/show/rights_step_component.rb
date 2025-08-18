# frozen_string_literal: true

module Show
  # Component for displaying step 6 in the show view.
  class RightsStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
