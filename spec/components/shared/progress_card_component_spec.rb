# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::ProgressCardComponent, type: :component do
  let(:submission) do
    build(:submission, citation_verified: 'true', abstract_provided: 'true', submitted_to_registrar: 'true',
                       submitted_at: DateTime.new(2023, 1, 1, 12, 0, 0))
  end

  it 'renders the list of steps' do
    render_inline(described_class.new(submission:))
    expect(page).to have_css('aside h2', text: 'Progress')
    expect(page).to have_css('li', count: TOTAL_PROGRESS_STEPS)
    expect(page).to have_css('.character-circle-disabled', count: TOTAL_STEPS - 3)
    expect(page).to have_css('.character-circle-success', count: 3)
    expect(page).to have_css('.character-circle-blank', count: 2)
    expect(page).to have_css('li:first-of-type[aria-label="Step 1, Citation details verified, Completed"]',
                             text: 'Citation details verified')
    expect(page).to have_css('li .text-muted', text: 'January  1, 2023 12:00pm')
  end
end
