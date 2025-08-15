# frozen_string_literal: true

module Edit
  # Component for editing step 7 of the submitter form
  class Step7Component < ApplicationComponent
    def initialize(submission_presenter:, form:)
      @submission_presenter = submission_presenter
      @form = form
      super()
    end

    attr_reader :submission_presenter, :form

    delegate :step7_done?, :copyright_statement, to: :submission_presenter

    def show?
      !step7_done?
    end

    def cc_license_options
      [['Select an option', '']].tap do |options|
        CreativeCommonsLicense.all.each do |license| # rubocop:disable Rails/FindEach
          options << [license.name, license.id]
        end
      end
    end

    def embargo_options
      Embargo.all.map do |embargo|
        [embargo.id, embargo.id]
      end
    end
  end
end
