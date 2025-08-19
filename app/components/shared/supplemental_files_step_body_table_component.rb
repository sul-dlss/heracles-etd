# frozen_string_literal: true

module Shared
  # Component for displaying the supplemental files step body table.
  class SupplementalFilesStepBodyTableComponent < ApplicationComponent
    def initialize(submission:, with_remove: false)
      @submission = submission
      @with_remove = with_remove
      super()
    end

    private

    attr_reader :submission, :with_remove

    delegate :supplemental_files, to: :submission
  end
end
