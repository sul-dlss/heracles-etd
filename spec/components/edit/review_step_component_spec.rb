# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::ReviewStepComponent, type: :component do
  let(:submission) { create(:submission, citation_verified: 'true') }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }

  it 'renders the step' do
    render_inline(described_class.new(step_number: 2, title: 'Step 2', form:, review_field: :citation_verified))

    expect(page).to have_css('.collapse-item[data-controller="confirm"]')

    header = page.find('.collapse-item .collapse-header')
    expect(header).to have_css('h2', text: 'Step 2')
    expect(header).to have_css('button.d-none[data-action="confirm#confirm submit-form#toggleAndSubmit"]',
                               text: 'Undo your confirmation')

    expect(page).to have_field('citation_verified', type: 'hidden', with: 'true')

    body = page.find('.collapse-item .collapse-body')
    expect(body).to have_css('button[data-action="confirm#confirm submit-form#toggleAndSubmit"][data-bs-target="#collapse_2"]', # rubocop:disable Layout/LineLength
                             text: 'Done')
  end
end
