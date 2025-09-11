# frozen_string_literal: true

module Show
  # Component for displaying citation step in the show view.
  class CitationStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      @step = SubmissionPresenter::CITATION_STEP
      super()
    end

    attr_reader :step, :submission
  end
end
