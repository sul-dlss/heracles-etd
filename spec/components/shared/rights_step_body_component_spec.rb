# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::RightsStepBodyComponent, type: :component do
  let(:submission) { create(:submission, embargo: '6 months', cclicense:) }
  let(:cclicense) { '1' }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    rows = page.all('table#copyright-details-table tbody tr')
    expect(rows.length).to eq(3)
    expect(rows[0]).to have_css('th', text: 'Copyright Statement')
    expect(rows[0]).to have_css('td', text: "© #{Time.zone.now.year} by Jane Doe. All rights reserved.")

    expect(rows[1]).to have_css('th', text: 'Creative Commons')
    expect(rows[1]).to have_css('td', text: 'This work is licensed under a CC Attribution license.')
    expect(rows[1]).to have_link('https://creativecommons.org/licenses/by/3.0/legalcode')
    expect(rows[1]).to have_css('img[src="https://licensebuttons.net/l/by/4.0/88x31.png"]')

    expect(rows[2]).to have_css('th', text: 'External Release')
    expect(rows[2]).to have_css('td', text: I18n.l(Time.zone.today + 6.months, format: :long))
  end

  context 'when the submission has no cc license' do
    let(:cclicense) { '0' }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      rows = page.all('table#copyright-details-table tbody tr')
      expect(rows.length).to eq(3)
      expect(rows[1]).to have_css('th', text: 'Creative Commons')
      expect(rows[1]).to have_css('td', text: 'This work is not licensed under a Creative Commons license.')
    end
  end
end
