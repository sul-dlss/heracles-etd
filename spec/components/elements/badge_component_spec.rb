# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::BadgeComponent, type: :component do
  it 'renders the badge' do
    render_inline(described_class.new(value: 'Test Badge'))
    expect(page).to have_css('div.badge.badge-primary', text: 'Test Badge')
  end

  context 'with a variant' do
    it 'renders the correct classes for variant' do
      render_inline(described_class.new(value: 'Test Badge', variant: :success))
      expect(page).to have_css('div.badge.badge-success', text: 'Test Badge')
    end
  end
end
