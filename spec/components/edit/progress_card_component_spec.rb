# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::ProgressCardComponent, type: :component do
  it 'renders the list of steps' do
    render_inline(described_class.new)
    expect(page).to have_css('li', count: 7)
    expect(page).to have_css('.character-circle-disabled', count: 7)
    expect(page).to have_css('.character-circle-success', count: 7)
    expect(page).to have_css('.character-circle-blank', count: 2)
  end
end
