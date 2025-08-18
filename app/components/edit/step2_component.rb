# frozen_string_literal: true

module Edit
  # Component for editing step 2 of the submitter form
  class Step2Component < ApplicationComponent
    def initialize(submission_presenter:)
      @submission_presenter = submission_presenter
      super()
    end

    attr_reader :submission_presenter

    delegate :step2_done?, :abstract, to: :submission_presenter

    def show?
      !step2_done?
    end
  end
end
