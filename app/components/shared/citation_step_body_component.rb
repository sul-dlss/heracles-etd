# frozen_string_literal: true

module Shared
  # Component for the body of citation step.
  class CitationStepBodyComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :schoolname, :department, :degree, :major, :degreeconfyr, :title, :orcid,
             to: :submission
  end
end
