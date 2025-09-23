# frozen_string_literal: true

module ReaderReview
  # Component for displaying the permission files step in the reader review view.
  class PermissionFilesComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    delegate :permission_files, to: :submission

    attr_reader :submission
  end
end
