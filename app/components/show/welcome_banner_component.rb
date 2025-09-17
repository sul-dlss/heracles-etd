# frozen_string_literal: true

module Show
  # Component for displaying a welcome banner on the submission page
  class WelcomeBannerComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :ready_for_cataloging?, :first_name, :degree, to: :submission

    def title
      return 'Submission successful.' unless ready_for_cataloging?

      'Submission approved.'
    end

    def body_component
      return WelcomeBannerProcessingBodyComponent.new(submission:) unless ready_for_cataloging?

      WelcomeBannerApprovedBodyComponent.new(submission:)
    end
  end
end
