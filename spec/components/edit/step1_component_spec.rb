# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::Step1Component, type: :component do
  let(:submission_presenter) { SubmissionPresenter.new(submission:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }
  let(:submission) { create(:submission) }

  it 'renders the component' do
    render_inline(described_class.new(submission_presenter:, form:))

    expect(page).to have_css('h2', text: 'Verify your citation details')
    expect(page).to have_css('h3', text: 'Citation details')
  end
end
