# frozen_string_literal: true

module Edit
  # Component for editing step 1 of the submitter form
  class Step1Component < ApplicationComponent
    def initialize(submission_presenter:, form:)
      @submission_presenter = submission_presenter
      @form = form
      super()
    end

    attr_reader :submission_presenter, :form

    delegate :step1_done?, to: :submission_presenter

    def show?
      !step1_done?
    end
  end
end
