# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::RightsStepBodyComponent, type: :component do
  let(:submission) { create(:submission, embargo:, cclicense:, last_registrar_action_at:, regapproval:) }
  let(:embargo) { '6 months' }
  let(:cclicense) { '1' }
  let(:last_registrar_action_at) { nil }
  let(:regapproval) { nil }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    rows = page.all('table#copyright-details-table tbody tr')
    expect(rows.length).to eq(4)
    expect(rows[0]).to have_css('th', text: 'Copyright Statement')
    expect(rows[0]).to have_css('td', text: "© #{Time.zone.now.year} by Jane Doe. All rights reserved.")

    expect(rows[1]).to have_css('th', text: 'Creative Commons')
    expect(rows[1]).to have_css('td', text: 'This work is licensed under a CC Attribution license.')
    expect(rows[1]).to have_link('https://creativecommons.org/licenses/by/3.0/legalcode')

    expect(rows[2]).to have_css('th', text: 'External Release')
    expect(rows[2]).to have_css(
      'td',
      text: 'The author has requested that this thesis be made publicly available 6 months ' \
            'after final approval by the Registrar.'
    )
  end

  context 'when the submission is barebones (e.g., no license selected)' do
    let(:submission) { create(:submission) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      rows = page.all('table#copyright-details-table tbody tr')
      expect(rows.length).to eq(4)
      expect(rows[1]).to have_css('th', text: 'Creative Commons')
      expect(rows[1]).to have_css('td', text: 'This work has not yet been licensed.')
    end
  end

  context 'when the submission has no cc license' do
    let(:cclicense) { '0' }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      rows = page.all('table#copyright-details-table tbody tr')
      expect(rows.length).to eq(4)
      expect(rows[1]).to have_css('th', text: 'Creative Commons')
      expect(rows[1]).to have_css('td', text: 'This work is not licensed under a Creative Commons license.')
    end
  end

  context 'when embargo is blank and the registrar has not yet approved' do
    let(:embargo) { nil }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      rows = page.all('table#copyright-details-table tbody tr')
      expect(rows[2]).to have_css(
        'td',
        text: "This #{submission.etd_type.downcase} will be publicly available after final approval by " \
              "the Registrar's Office and processing by the Stanford University Libraries."
      )
    end
  end

  context 'when embargo is immediate and the registrar has approved' do
    let(:embargo) { 'immediately' }
    let(:last_registrar_action_at) { Time.zone.parse('2020-03-06T12:38:00Z') }
    let(:regapproval) { 'Approved' }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      rows = page.all('table#copyright-details-table tbody tr')
      expect(rows[2]).to have_css('td', text: 'This thesis will be publicly available on ' \
                                              'March 06, 2020.')
    end
  end
end
