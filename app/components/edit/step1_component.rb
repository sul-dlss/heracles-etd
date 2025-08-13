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

    delegate :step1_done?, :schoolname, :department, :degree, :major, :degreeconfyr, :title, :orcid,
             to: :submission_presenter

    def show?
      !step1_done?
    end

    def orcid_text
      <<~TEXT
        If you have granted Stanford permission to update your ORCID profile, your thesis or dissertation will be
        automatically added to your profile. You can always manually add or change the work appearing in
        your profile at a later date.
      TEXT
    end
  end
end
