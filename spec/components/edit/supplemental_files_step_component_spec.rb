# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::SupplementalFilesStepComponent, type: :component do
  let(:submission) { create(:submission, supplemental_files_provided:) }
  let(:supplemental_files_provided) { 'false' }

  context 'without an attached supplemental file' do
    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Upload supplemental files')
      expect(page).to have_no_field('Upload supplemental files', type: 'file')
      expect(page).to have_no_content('You can upload a maximum of 2 supplemental files.')
    end
  end

  context 'with the supplemental file provided flag' do
    let(:supplemental_files_provided) { 'true' }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Upload supplemental files')
      expect(page).to have_field('Upload supplemental files', type: 'file')
      expect(page).to have_content('You can upload a maximum of 2 supplemental files.')
    end

    context 'with attached supplemental files' do
      let(:submission) { create(:submission, :with_supplemental_files, supplemental_files_provided:) }

      it 'renders the component' do
        render_inline(described_class.new(submission:))

        expect(page).to have_css('h2', text: 'Upload supplemental files')
        expect(page).to have_css('table#supplemental-files-table tr', count: 5)
        rows = page.all('table#supplemental-files-table tbody tr')
        cells = rows[0].all('td')
        expect(cells[3]).to have_button('Remove', type: 'submit')
        cells = rows[1].all('th')
        expect(cells[0]).to have_field('File description:', type: 'text')
        cells = rows[2].all('td')
        expect(cells[3]).to have_button('Remove', type: 'submit')
        cells = rows[3].all('th')
        expect(cells[0]).to have_field('File description:', type: 'text')
      end
    end
  end
end
