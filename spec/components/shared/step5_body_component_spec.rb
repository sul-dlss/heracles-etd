# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::Step5BodyComponent, type: :component do
  context 'when editing a submission with supplemental files' do
    let(:submission) { create(:submission, with_supplemental_files: true) }
    let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }

    it 'renders the component with upload file fields' do
      render_inline(described_class.new(submission:, form:))
      expect(page).to have_table('supplemental-files-table')
      expect(page).to have_button('Upload supplemental file')
    end
  end

  context 'when displaying a submission for review' do
    let(:submission) { create(:submission, :submittable) }

    it 'renders the component with upload file fields' do
      render_inline(described_class.new(submission:))
      expect(page).to have_table('supplemental-files-table')
      expect(page).to have_content(submission.supplemental_files.first.filename)
      expect(page).to have_content(submission.supplemental_files.last.filename)
      expect(page).to have_no_button('Upload more supplemental files')
    end
  end
end
