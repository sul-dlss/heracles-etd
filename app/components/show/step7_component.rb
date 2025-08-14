# frozen_string_literal: true

module Show
  # Component for displaying step 7 in the show view.
  class Step7Component < ApplicationComponent
    def initialize(submission:)
      @submission = submission

      super()
    end

    attr_reader :submission

    delegate :submitted_at, to: :submission
  end
end
