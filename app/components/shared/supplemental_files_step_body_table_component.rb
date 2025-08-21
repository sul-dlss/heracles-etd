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

    def remove_btn_data
      # After a file is removed, set the focus to the file input.
      {
        action: 'click->focus#saveFocus',
        focus_id_param: helpers.submission_form_field_id(submission, :supplemental_files)
      }
    end
  end
end
