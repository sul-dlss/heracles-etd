# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::ProgressCardStepComponent, type: :component do
  context 'when success variant' do
    it 'renders the step' do
      render_inline(described_class.new(variant: :success, label: 'Verified citation'))
      expect(page).to have_css('.character-circle-success.character-circle-check', text: '') # U+F633
      expect(page).to have_css('div', text: 'Verified citation')
    end
  end

  context 'when disabled variant' do
    it 'renders the step' do
      render_inline(described_class.new(variant: :disabled, label: 'Verified citation', character: '1'))
      expect(page).to have_css('.character-circle-disabled', text: '1')
      expect(page).to have_css('div', text: 'Verified citation')
    end
  end

  context 'with step_at' do
    it 'renders the step' do
      render_inline(described_class.new(variant: :disabled, label: 'Verified citation', character: '1',
                                        step_at: DateTime.parse('2023-01-01 12:00:00')))

      expect(page).to have_css('div.text-muted', text: 'January  1, 2023 12:00pm')
    end
  end
end
