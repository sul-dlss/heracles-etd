# frozen_string_literal: true

module Edit
  # Component for editing step 3 of the submitter form
  class Step3Component < ApplicationComponent
    def initialize(submission_presenter:, form:)
      @submission_presenter = submission_presenter
      @form = form
      super()
    end

    def show?
      !@submission_presenter.step3_done?
    end

    attr_reader :form
  end
end
