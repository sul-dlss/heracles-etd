# frozen_string_literal: true

module Edit
  # Component for editing step 8 of the submitter form
  class Step8Component < ApplicationComponent
    def initialize(submission_presenter:, form:)
      @submission_presenter = submission_presenter
      @form = form

      super()
    end

    attr_reader :submission_presenter, :form

    delegate :all_done?, to: :submission_presenter
  end
end
