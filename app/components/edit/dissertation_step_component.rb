# frozen_string_literal: true

module Edit
  # Component for editing the dissertation upload step of the submitter form
  class DissertationStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :dissertation_file, to: :submission

    def done_disabled?
      !dissertation_file.attached?
    end
  end
end
