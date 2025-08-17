# frozen_string_literal: true

module Edit
  # Component for editing the format step of the submitter form
  class FormatStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission
  end
end
