# frozen_string_literal: true

# Run the SubmissionPoster service
class PostSubmissionJob < ApplicationJob
  queue_as :post_submission

  def perform(submission:)
    SubmissionPoster.call(submission:)
  end
end
