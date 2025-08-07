# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ExternalLinkComponent, type: :component do
  context 'when label is provided' do
    it 'renders the external link' do
      render_inline(described_class.new(url: 'https://example.com', label: 'Example'))

      expect(page).to have_css("a[href='https://example.com'][target='_blank'][rel='noopener']", text: 'Example')
    end
  end

  context 'when content is provided' do
    it 'renders the external link with content' do
      render_inline(described_class.new(url: 'https://example.com')) do
        'Visit Example'
      end

      expect(page).to have_css("a[href='https://example.com'][target='_blank'][rel='noopener']", text: 'Visit Example')
    end
  end
end
