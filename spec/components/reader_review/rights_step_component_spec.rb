# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReaderReview::RightsStepComponent, type: :component do
  context 'with a registrar action date' do
    let(:submission) { create(:submission, embargo: '6 months', cclicense: '1', last_registrar_action_at: 2.years.ago) }
    let(:release_date_display) { (2.years.ago + 6.months).to_date.strftime('%B %d, %Y') }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Copyright and license terms')
      rows = page.all('table#copyright-details-table tbody tr')
      expect(rows.length).to eq(3)
      expect(page).to have_content(release_date_display)
    end
  end

  context 'without a registrar action date' do
    let(:submission) { create(:submission, embargo: '6 months', cclicense: '1') }
    let(:release_date_display) { 6.months.from_now.to_date.strftime('%B %d, %Y') }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_content(release_date_display)
    end
  end
end
