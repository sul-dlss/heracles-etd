# frozen_string_literal: true

module Edit
  # Component for editing the supplemental files upload step of the submitter form
  class SupplementalFilesStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :supplemental_files, to: :submission
  end
end
