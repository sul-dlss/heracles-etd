# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::SupplementalFilesStepComponent, type: :component do
  context 'without an attached supplemental file' do
    let(:submission) { create(:submission) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Add supplemental files (optional)')
      expect(page).to have_field('Upload supplemental files', type: 'file')
    end
  end

  context 'with attached supplemental files' do
    let(:submission) { create(:submission, :with_supplemental_files) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Add supplemental files (optional)')
      expect(page).to have_css('table#supplemental-files-table tr', count: 3)
      rows = page.all('table#supplemental-files-table tbody tr')
      cells = rows[0].all('td')
      expect(cells[4]).to have_button('Remove', type: 'submit')
      cells = rows[1].all('td')
      expect(cells[4]).to have_button('Remove', type: 'submit')
    end
  end
end
