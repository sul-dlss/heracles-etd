# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::Step3Component, type: :component do
  let(:submission) { create(:submission) }
  let(:submission_presenter) { SubmissionPresenter.new(submission:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }

  it 'renders the component' do
    render_inline(described_class.new(form:, submission_presenter:))
    expect(page).to have_css('h2', text: 'Review your dissertation\'s formatting')
    expect(page).to have_css('table#formatting-table th', text: 'Title Page')
    expect(page).to have_css('table#formatting-table td', text: 'Should not be physically numbered')
    expect(page).to have_css('.border-1', count: 5)
    expect(page).to have_css('.border-1', text: 'Title Page')
  end
end
