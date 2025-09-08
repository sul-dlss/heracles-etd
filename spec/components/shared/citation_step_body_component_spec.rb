# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::CitationStepBodyComponent, type: :component do
  context 'when submission does not have an orcid' do
    let(:submission) { create(:submission) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h3', text: 'Citation details')
      rows = page.find_all('#citation-details-table tr')
      expect(rows.size).to eq(7)
      expect(rows[0]).to have_css('th', text: 'School')
      expect(rows[0]).to have_css('td', text: submission.schoolname)

      expect(page).to have_css('#orcid-details-table tr th', text: 'ORCID iD')
      expect(page).to have_css('#orcid-details-table tr td', text: 'Not found')
      expect(page).to have_css('.alert.alert-warning', text: 'ORCID iD not found')
    end
  end

  context 'when submission has an orcid' do
    let(:submission) { create(:submission, :with_orcid) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('#orcid-details-table tr th', text: 'ORCID iD')
      expect(page).to have_css('#orcid-details-table tr td', text: '0000-0002-1825-0097')
      expect(page).to have_css('.alert.alert-info', text: 'Your ORCID iD')
    end
  end
end
