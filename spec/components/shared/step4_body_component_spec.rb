# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::Step4BodyComponent, type: :component do
  context 'when editing a submission' do
    let(:submission) { create(:submission) }
    let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }

    it 'renders the component with upload file fields' do
      render_inline(described_class.new(submission:, form:))
      expect(page).to have_table('dissertation-file-table')
      expect(page).to have_button('Upload PDF')
    end
  end

  context 'when displaying a submission for review' do
    let(:submission) { create(:submission, :submittable) }

    it 'renders the component with upload file fields' do
      render_inline(described_class.new(submission:))
      expect(page).to have_table('dissertation-file-table')
      expect(page).to have_content(submission.dissertation_file.filename)
      expect(page).to have_no_button('Upload PDF')
    end
  end
end
