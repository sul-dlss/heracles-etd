# frozen_string_literal: true

module Shared
  # Component for the body of step 4 (dissertation file).
  class Step4BodyComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :dissertation_file, to: :submission

    def values_for_dissertation_file
      return [] unless dissertation_file.attached?

      [
        filename || '[No file selected]',
        'PDF',
        number_to_human_size(byte_size),
        uploaded_at
      ]
    end

    private

    def byte_size
      return unless dissertation_file.byte_size.presence

      number_to_human_size(dissertation_file.byte_size)
    end

    def filename
      dissertation_file.filename.presence || '[No file selected]'
    end

    def uploaded_at
      return unless dissertation_file.created_at.presence

      l(dissertation_file.created_at)
    end
  end
end
