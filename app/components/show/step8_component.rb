# frozen_string_literal: true

module Show
  # Component for displaying step 8 in the show view.
  class Step8Component < ApplicationComponent
    def initialize(submission:)
      @submission = submission

      super()
    end

    attr_reader :submission

    delegate :submitted_at, to: :submission
  end
end
