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

    def orcid_text
      <<~TEXT
        If you have granted Stanford permission to update your ORCID profile, your thesis or dissertation will be
        automatically added to your profile. You can always manually add or change the work appearing in
        your profile at a later date.
      TEXT
    end
  end
end
