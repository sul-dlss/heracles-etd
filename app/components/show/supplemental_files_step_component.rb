# frozen_string_literal: true

module Show
  # Component for displaying the supplemental files step in the show view.
  class SupplementalFilesStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :supplemental_files, to: :submission
  end
end
