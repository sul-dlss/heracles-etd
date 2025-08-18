# frozen_string_literal: true

module Edit
  # Component for editing the citation step of the submission form
  class CitationStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
