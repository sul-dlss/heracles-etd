# frozen_string_literal: true

module Edit
  # Component for editing step 4 (Dissertation file) of the submitter form
  class Step4Component < ApplicationComponent
    def initialize(submission_presenter:, form:)
      @submission_presenter = submission_presenter
      @form = form
      super()
    end

    attr_reader :submission_presenter, :form

    delegate :step4_done?, to: :submission_presenter

    def show?
      !@submission_presenter.step4_done?
    end
  end
end
