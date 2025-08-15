# frozen_string_literal: true

module Shared
  # Component for the body of step 4 (dissertation file).
  class Step4BodyComponent < ApplicationComponent
    def initialize(submission:, form: nil)
      @submission = submission
      @form = form
      super()
    end

    attr_reader :submission, :form

    delegate :dissertation_file, to: :submission

    def supplemental_files
      Array(submission.supplemental_files).append(nil)
    end
  end
end
