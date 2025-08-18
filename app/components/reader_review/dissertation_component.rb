# frozen_string_literal: true

module ReaderReview
  # Component for displaying the dissertation files step in the reader review view.
  class DissertationComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
