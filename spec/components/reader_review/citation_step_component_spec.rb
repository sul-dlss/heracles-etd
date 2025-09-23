# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReaderReview::CitationStepComponent, type: :component do
  let(:submission) { create(:submission, :with_advisors) }
  let(:reader) { submission.readers.first }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('h2', text: 'Citation details')
    rows = page.find_all('#citation-details-table tr')
    expect(rows.size).to eq(9)
    expect(rows[0]).to have_css('th', text: 'Name')
    expect(rows[0]).to have_css('td', text: submission.first_last_name)
    expect(rows[1]).to have_css('th', text: 'School')
    expect(rows[1]).to have_css('td', text: submission.schoolname)
    expect(rows[6]).to have_css('th', text: 'Reading Committee')
    expect(rows[6]).to have_css('td', text: reader)
  end
end
