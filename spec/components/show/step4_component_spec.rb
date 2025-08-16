# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::Step4Component, type: :component do
  context 'when displaying a submission' do
    let(:submission) { create(:submission, :submittable) }

    it 'renders the component with upload file fields' do
      render_inline(described_class.new(submission:))
      expect(page).to have_table('dissertation-file-table')
      expect(page).to have_content(submission.dissertation_file.filename)
      expect(page).to have_no_button('Upload PDF')
    end
  end
end
