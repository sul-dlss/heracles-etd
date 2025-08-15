# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::Step5Component, type: :component do
  let(:submission_presenter) { SubmissionPresenter.new(submission:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }

  context 'when supplemental files are not included' do
    let(:submission) { create(:submission) }

    it 'renders the component closed' do
      render_inline(described_class.new(form:, submission_presenter:))
      expect(page).to have_css('h2', text: 'Supplemental files (optional)')
    end
  end

  context 'when supplemental files are included' do
    let(:submission) { create(:submission, with_supplemental_files: true) }

    it 'renders the component closed' do
      render_inline(described_class.new(form:, submission_presenter:))
      expect(page).to have_css('h2', text: 'Supplemental files (optional)')
      expect(page).to have_button('Upload supplemental file')
    end
  end
end
