# frozen_string_literal: true

module Edit
  # Component for editing step 3 of the submitter form
  class Step3Component < ApplicationComponent
    def initialize(submission_presenter:)
      @submission_presenter = submission_presenter
      super()
    end

    def show?
      !submission_presenter.step3_done?
    end

    attr_reader :submission_presenter
  end
end
