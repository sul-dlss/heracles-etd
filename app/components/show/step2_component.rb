# frozen_string_literal: true

module Show
  # Component for displaying step 2 in the show view.
  class Step2Component < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
