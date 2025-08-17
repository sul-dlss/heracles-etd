# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::FormatStepBodyComponent, type: :component do
  it 'renders the component' do
    render_inline(described_class.new)
    expect(page).to have_css('table#formatting-table th', text: 'Title Page')
    expect(page).to have_css('table#formatting-table td', text: 'Should not be physically numbered')
    expect(page).to have_css('.border-1', count: 5)
    expect(page).to have_css('.border-1', text: 'Title Page')
  end
end
