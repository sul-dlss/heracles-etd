# frozen_string_literal: true

module Show
  # Component for displaying a welcome banner on the submission page after approval
  class WelcomeBannerApprovedBodyComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :first_name, :dissertation_id, :degree, :purl, :doi, to: :submission
  end
end
