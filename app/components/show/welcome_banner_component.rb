# frozen_string_literal: true

module Show
  # Component for displaying a welcome banner on the submission page
  class WelcomeBannerComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :approved?, :first_name, :degree, to: :submission

    def title
      return 'Submission successful.' unless approved?

      'Submission approved.'
    end

    def body_component
      return WelcomeBannerProcessingBodyComponent.new(submission: submission) unless approved?

      WelcomeBannerApprovedBodyComponent.new(submission: submission)
    end
  end
end
