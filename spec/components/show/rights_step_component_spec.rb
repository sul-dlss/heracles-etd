# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::RightsStepComponent, type: :component do
  let(:submission) { create(:submission, embargo: '6 months', cclicense: '1') }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('h2', text: 'Apply copyright and license terms')
    rows = page.all('table#copyright-details-table tbody tr')
    expect(rows.length).to eq(4)
  end
end
