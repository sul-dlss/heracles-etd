# frozen_string_literal: true

module Edit
  # Component for editing the abstract step of the submitter form
  class AbstractStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    def done_disabled?
      submission.abstract.blank?
    end
  end
end
