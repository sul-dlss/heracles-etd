# frozen_string_literal: true

module Show
  # Component for showing step 1
  class Step1Component < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
