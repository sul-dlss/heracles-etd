# frozen_string_literal: true

module Show
  # Component for displaying the dissertation step in the show view.
  class DissertationStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
