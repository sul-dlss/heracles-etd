# frozen_string_literal: true

module Edit
  # Component for dissertation file upload
  class DissertationFileComponent < ApplicationComponent
    def initialize(dissertation_file:)
      @dissertation_file = dissertation_file
      super()
    end

    attr_reader :dissertation_file

    delegate :attached?, :filename, :byte_size, :created_at, :record, to: :@dissertation_file

    def values_for_dissertation_file
      [
        filename || '[No file selected]',
        'PDF',
        number_to_human_size(byte_size),
        uploaded_at,
        dissertation_file_remove_link
      ]
    end

    private

    def uploaded_at
      return unless attached?

      l(created_at)
    end

    def dissertation_file_remove_link
      return unless attached?

      link_to('Remove', submission_attachment_path(submission.dissertation_id, file_id: dissertation_file.id))
    end

    def submission
      @submission ||= record
    end
  end
end
