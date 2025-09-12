# frozen_string_literal: true

module ApplicationHelper
  def with_submission_form(submission, &)
    form_with model: submission, url: submission_path(submission) do |form|
      yield(form) if block_given?
    end
  end

  def submission_form_field_id(submission, field)
    with_submission_form(submission) do |form|
      return form.field_id(field)
    end
  end

  def required_field
    content_tag(:span, '* Required', class: 'text-danger')
  end

  def human_content_type(content_type)
    content_type.split('/').last
  end
end
