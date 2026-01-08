# frozen_string_literal: true

module Edit
  # Component for editing the abstract step of the submitter form
  class AbstractStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    # Do not enable the Done button if the abstract is blank or exceeds max length of 5000 chars
    def done_disabled?
      submission.abstract.blank? || submission.abstract.length > 5000
    end
  end
end
