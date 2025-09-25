# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReaderReview::RightsStepComponent, type: :component do
  context 'with a registrar action date' do
    let(:submission) do
      create(:submission, :ready_for_cataloging, embargo: '6 months', cclicense: '1',
                                                 last_registrar_action_at: 2.years.ago)
    end
    let(:release_date_display) { (2.years.ago + 6.months).to_date.strftime('%B %d, %Y') }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Copyright and license terms')
      rows = page.all('table#copyright-details-table tbody tr')
      expect(rows.length).to eq(4)
      expect(page).to have_content(
        "This thesis will be publicly available on #{release_date_display} " \
        '(includes 6-month delay requested by the author).'
      )
    end
  end

  context 'without a registrar action date' do
    let(:submission) { create(:submission, embargo: '6 months', cclicense: '1') }

    it 'renders the component' do
      render_inline(described_class.new(submission:))
      expect(page).to have_content(
        'The author has requested that this thesis be made publicly available ' \
        '6 months after final approval by the Registrar.'
      )
    end
  end
end
