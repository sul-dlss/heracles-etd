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

    def max_files
      Settings.supplemental_files.max_files
    end

    def form_data
      {
        controller: 'files',
        files_max_files_value: max_files,
        files_existing_files_value: supplemental_files.size
      }
    end

    def file_field_data
      {
        controller: 'submit',
        action: 'files#validate submit#submit'
      }
    end
  end
end
