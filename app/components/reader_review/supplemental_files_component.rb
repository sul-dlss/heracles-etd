# frozen_string_literal: true

module ReaderReview
  # Component for displaying the supplemental files step in the reader review view.
  class SupplementalFilesComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
