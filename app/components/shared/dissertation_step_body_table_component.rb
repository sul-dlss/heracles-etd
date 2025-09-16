# frozen_string_literal: true

module Shared
  # Component for displaying the dissertation step body table.
  class DissertationStepBodyTableComponent < ApplicationComponent
    def initialize(submission:, with_remove: false)
      @submission = submission
      @with_remove = with_remove
      super()
    end

    private

    attr_reader :submission, :with_remove

    delegate :dissertation_file, to: :submission

    delegate :filename, :byte_size, :created_at, to: :dissertation_file

    def file_size
      helpers.number_to_human_size(byte_size)
    end

    def remove_btn_data
      # After a file is removed, set the focus to the file input.
      {
        action: 'click->focus#saveFocus',
        focus_id_param: helpers.submission_form_field_id(submission, :dissertation_file)
      }
    end

    def dissertation_file?
      dissertation_file.attached?
    end
  end
end
