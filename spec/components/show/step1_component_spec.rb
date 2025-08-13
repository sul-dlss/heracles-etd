# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::Step1Component, type: :component do
  let(:submission) { create(:submission) }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('h2', text: 'Citation details')
    expect(page).to have_css('h3', text: 'Citation details')
  end
end
