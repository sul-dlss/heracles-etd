# frozen_string_literal: true

module Shared
  # Component for rendering the body of step 4 (dissertation file).
  class Step4BodyComponent < ApplicationComponent
    # param [Submission] the submission being edited
    # param [ActionView::Helpers::FormBuilder, nil] form (not included for the show page)
    def initialize(submission:, form: nil)
      @submission = submission
      @form = form
      super()
    end

    attr_reader :submission, :form

    delegate :dissertation_file, :supplemental_files, to: :submission
  end
end
