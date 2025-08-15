# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReaderReview::Step2Component, type: :component do
  let(:submission) { create(:submission, abstract: 'My abstract') }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('h2', text: 'Abstract')
    expect(page).to have_css('p', text: 'My abstract')
  end
end
