# frozen_string_literal: true

module Edit
  # Component for editing the supplemental files upload step of the submitter form
  class SupplementalFilesStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :supplemental_files, :supplemental_files_provided?, to: :submission

    def no_supplemental_files_action
      supplemental_files.any? ? 'click->submit#warn' : 'submit#submit'
    end

    def done_disabled?
      return false unless supplemental_files_provided?

      supplemental_files.none?
    end
  end
end
