# frozen_string_literal: true

module Shared
  # Component for displaying the permission files step body table.
  class PermissionFilesStepBodyTableComponent < ApplicationComponent
    def initialize(submission:, with_remove: false)
      @submission = submission
      @with_remove = with_remove
      super()
    end

    private

    attr_reader :submission, :with_remove

    delegate :permission_files, to: :submission

    def remove_btn_data
      # After a file is removed, set the focus to the file input.
      {
        action: 'click->focus#saveFocus',
        focus_id_param: helpers.submission_form_field_id(submission, :permission_files)
      }
    end
  end
end
