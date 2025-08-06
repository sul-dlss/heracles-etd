# frozen_string_literal: true

module Edit
  # Component for the welcome section of the edit submission page
  class WelcomeComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :first_name, :dissertation_id, to: :submission
  end
end
