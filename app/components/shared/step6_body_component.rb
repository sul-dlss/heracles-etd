# frozen_string_literal: true

module Shared
  # Component for rendering the body of step 6.
  class Step6BodyComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :copyright_statement, to: :submission

    def embargo_date
      Embargo.embargo_date(start_date: Time.zone.now, id: submission.embargo).to_date
    end

    def license
      CreativeCommonsLicense.find(submission.cclicense)
    end
  end
end
