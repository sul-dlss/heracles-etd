# frozen_string_literal: true

module Edit
  # Component for editing step 2 of the submitter form
  class Step2Component < ApplicationComponent
    def initialize(submission_presenter:, form:)
      @submission_presenter = submission_presenter
      @form = form
      super()
    end

    attr_reader :submission_presenter, :form

    delegate :step2_done?, to: :submission_presenter

    def show?
      !step2_done?
    end
  end
end
