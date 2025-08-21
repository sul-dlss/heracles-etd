# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::ProgressCardStepComponent, type: :component do
  context 'when success variant' do
    it 'renders the step' do
      render_inline(described_class.new(variant: :success, label: 'Verified citation',
                                        aria_label: 'Step 1, Verified citation, Completed'))

      expect(page).to have_css('div[aria-label="Step 1, Verified citation, Completed"]')
      expect(page).to have_css('.character-circle-success', text: '✓')
      expect(page).to have_css('div', text: 'Verified citation')
    end
  end

  context 'when disabled variant' do
    it 'renders the step' do
      render_inline(described_class.new(variant: :disabled, label: 'Verified citation', character: '1',
                                        aria_label: 'Step 1, Verified citation, In progress'))

      expect(page).to have_css('div[aria-label="Step 1, Verified citation, In progress"]')
      expect(page).to have_css('.character-circle-disabled', text: '1')
      expect(page).to have_css('div', text: 'Verified citation')
    end
  end

  context 'with step_at' do
    it 'renders the step' do
      render_inline(described_class.new(variant: :disabled, label: 'Verified citation', character: '1',
                                        aria_label: 'Step 1, Verified citation, In progress',
                                        step_at: DateTime.parse('2023-01-01 12:00:00')))

      expect(page).to have_css('div.text-muted', text: 'January  1, 2023 12:00pm')
    end
  end
end
