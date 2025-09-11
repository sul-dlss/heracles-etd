# frozen_string_literal: true

# Base component for all components in the application.
class ApplicationComponent < BaseComponent
  def step_complete?
    SubmissionPresenter.step_done?(step:, submission:)
  end
end
