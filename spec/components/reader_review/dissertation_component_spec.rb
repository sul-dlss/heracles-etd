# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReaderReview::DissertationComponent, type: :component do
  let(:submission) { create(:submission, :with_advisors, :submitted) }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('h2', text: 'Dissertation files')
    row = page.find('#dissertation-file-table tbody tr')
    expect(row).to have_link('dissertation.pdf')
  end
end
