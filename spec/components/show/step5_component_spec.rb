# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::Step5Component, type: :component do
  context 'when displaying a submission' do
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
