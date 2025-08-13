# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::Step2Component, type: :component do
  let(:submission) { create(:submission) }
  let(:submission_presenter) { SubmissionPresenter.new(submission:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }

  it 'renders the component' do
    render_inline(described_class.new(form: form, submission_presenter: submission_presenter))
    expect(page).to have_css('h2', text: 'Enter your abstract')
    expect(page).to have_css('textarea[name="abstract"]')
  end
end
