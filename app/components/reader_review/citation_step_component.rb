# frozen_string_literal: true

module ReaderReview
  # Component for displaying citation step in the reader review view.
  class CitationStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :first_last_name, :schoolname, :department, :degree, :major, :degreeconfyr, :title, :orcid,
             to: :submission

    def readers
      tag.ul class: 'list-unstyled mb-0' do
        safe_join(
          submission.readers.order(:position).map do |reader|
            tag.li(reader)
          end
        )
      end
    end
  end
end
