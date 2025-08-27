# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HeaderComponent, type: :component do
  let(:current_user) { User.new(remote_user: 'testuser') }

  it 'renders header' do
    render_inline(described_class.new(title: 'Test Header', subtitle: 'Test Subtitle', current_user:))

    expect(page).to have_css('header h1', text: 'Test Header')
    expect(page).to have_css('header .h4', text: 'Test Subtitle')
    expect(page).to have_text('Logged in: testuser')
  end
end
