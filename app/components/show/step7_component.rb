# frozen_string_literal: true

module Show
  # Component for displaying step 7 in the show view.
  class Step7Component < ApplicationComponent
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
