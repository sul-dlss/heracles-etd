# frozen_string_literal: true

module Edit
  # Component for displaying a welcome banner on the edit submission page
  class WelcomeBannerComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :first_last_name, :dissertation_id, :degree, to: :submission
  end
end
