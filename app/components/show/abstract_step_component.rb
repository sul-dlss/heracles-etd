# frozen_string_literal: true

module Show
  # Component for displaying the abstract step in the show view.
  class AbstractStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
