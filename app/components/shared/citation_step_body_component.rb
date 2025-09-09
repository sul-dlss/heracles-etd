# frozen_string_literal: true

module Shared
  # Component for the body of citation step.
  class CitationStepBodyComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :schoolname, :department, :degree, :major, :name, :degreeconfyr, :title, :orcid,
             to: :submission

    def readers
      tag.ul class: 'list-unstyled' do
        safe_join(
          submission.readers.order(:position).map do |reader|
            tag.li(reader)
          end
        )
      end
    end
  end
end
