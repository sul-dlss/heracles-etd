# frozen_string_literal: true

module ReaderReview
  # Component for displaying step 1 in the reader review view.
  class Step1Component < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :first_last_name, :schoolname, :department, :degree, :major, :degreeconfyr, :title, :orcid,
             to: :submission

    def advisors
      submission.readers.advisors.map(&:first_last_name).join('; ')
    end
  end
end
