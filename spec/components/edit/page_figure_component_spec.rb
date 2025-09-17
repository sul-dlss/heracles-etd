# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::PageFigureComponent, type: :component do
  it 'renders the page figure' do
    render_inline(described_class.new(title: 'Sample Title', with_x: true, footer: 'Sample Footer'))
    expect(page).to have_css('.border-1[aria-hidden="true"] small', text: 'Sample Title')
    expect(page).to have_css('.bottom-0.start-50', text: 'Sample Footer')
    expect(page).to have_css('.bi-x-circle')
  end
end
