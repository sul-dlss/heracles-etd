# frozen_string_literal: true

module Edit
  # Component for editing the rights step of the submitter form
  class RightsStepComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :copyright_statement, :sulicense, :cclicense, :embargo, to: :submission

    def cc_license_options
      [['Select an option', '']].tap do |options|
        CreativeCommonsLicense.all.each do |license| # rubocop:disable Rails/FindEach
          options << [license.name, license.id]
        end
      end
    end

    def embargo_options
      [['Select an option', '']].tap do |options|
        Embargo.all.map do |embargo|
          options << [embargo.id, embargo.id]
        end
      end
    end

    def done_disabled?
      !sulicense || cclicense.blank? || embargo.blank?
    end
  end
end
