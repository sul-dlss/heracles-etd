# frozen_string_literal: true

module Show
  # Component for displaying the first step in the show view.
  class Step1Component < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
