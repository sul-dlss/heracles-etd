# frozen_string_literal: true

module ReaderReview
  # Component for displaying step 7 in the reader review view.
  class Step7Component < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
