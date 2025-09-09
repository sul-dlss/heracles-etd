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

    def edit_focus_id
      # Focus on the file upload field.
      helpers.submission_form_field_id(submission, :supplemental_files)
    end

    def no_supplemental_files_action
      supplemental_files.any? ? 'click->submit#warn' : 'submit#submit'
    end
  end
end
