# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::Step2Component, type: :component do
  context 'when submission does not have an orcid' do
    let(:submission) { create(:submission) }
    let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }

    it 'renders the component' do
      render_inline(described_class.new(form:))
      expect(page).to have_css('h2', text: 'Enter your abstract')
      expect(page).to have_css('textarea[name="abstract"]')
    end
  end
end
