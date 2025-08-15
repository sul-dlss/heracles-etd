# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FooterComponent, type: :component do
  it 'renders footer' do
    render_inline(described_class.new)

    expect(page).to have_css('footer')
  end
end
