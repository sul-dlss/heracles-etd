# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::CharacterCircleComponent, type: :component do
  it 'renders the character in a circle' do
    render_inline(described_class.new(character: '1'))
    expect(page).to have_css('div.character-circle.character-circle-disabled', text: '1')
  end

  context 'when unknown variant is provided' do
    it 'raises an ArgumentError' do
      expect { render_inline(described_class.new(character: 'A', variant: :unknown)) }.to raise_error(ArgumentError)
    end
  end

  context 'when multiple characters are provided' do
    it 'raises an ArgumentError' do
      expect { render_inline(described_class.new(character: 'AB')) }.to raise_error(ArgumentError)
    end
  end
end
