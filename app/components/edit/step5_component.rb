# frozen_string_literal: true

module Edit
  # Component for editing step 5 (Supplemental files) of the submitter form
  class Step5Component < ApplicationComponent
    def initialize(submission_presenter:, form:)
      @submission_presenter = submission_presenter
      @form = form
      super()
    end

    attr_reader :submission_presenter, :form

    delegate :step5_done?, to: :submission_presenter

    def show?
      !@submission_presenter.step5_done?
    end
  end
end
