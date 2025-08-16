# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::Step7Component, type: :component do
  let(:submission) { create(:submission, name: 'Doe, Jane') }
  let(:submission_presenter) { SubmissionPresenter.new(submission:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }

  it 'renders the component' do
    render_inline(described_class.new(submission_presenter:, form:))
    expect(page).to have_css('h2', text: 'Apply copyright and license terms')
    rows = page.all('table#copyright-details-table tr')
    expect(rows[0]).to have_css('th', text: 'Copyright Statement')
    expect(rows[0]).to have_css('td', text: '© 2025 by Jane Doe. All rights reserved.')

    expect(rows[1]).to have_css('th', text: 'Stanford License')
    expect(rows[1]).to have_link('View the Stanford University publication license', href: '#stanford-license-confirm')
    expect(rows[1]).to have_unchecked_field('sulicense')

    expect(rows[2]).to have_css('th', text: 'Creative Commons')
    expect(rows[2]).to have_link('View the Creative Commons licenses')
    expect(rows[2]).to have_select('cclicense', selected: 'Select an option')

    expect(rows[3]).to have_css('th', text: 'External Release')
    expect(rows[3]).to have_select('embargo')
  end
end
