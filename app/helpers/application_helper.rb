# frozen_string_literal: true

module ApplicationHelper
  def with_submission_form(submission, &)
    form_with model: submission, url: submission_path(submission.dissertation_id) do |form|
      yield(form) if block_given?
    end
  end
end
