# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::FormatStepComponent, type: :component do
  let(:submission) { create(:submission) }

  it 'renders the component' do
    render_inline(described_class.new(submission:))
    expect(page).to have_css('h2', text: 'Review your dissertation\'s formatting')
    expect(page).to have_css('table#formatting-table th', text: 'Title Page')
    expect(page).to have_css('.border-1', count: 5)
    expect(page).to have_button('Confirm')
  end
end
