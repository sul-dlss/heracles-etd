# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::AttachedFilesComponent, type: :component do
  context 'when a dissertation file is attached' do
    let(:submission) do
      create(:submission,
             dissertation_file: fixture_file_upload('dissertation.pdf', 'application/pdf'))
    end

    it 'renders the table with the filename instead of the upload link' do
      render_inline(described_class.new(file_type: 'dissertation',
                                        files: submission.dissertation_file,
                                        label: 'Dissertation File',
                                        required_file_type: 'PDF',
                                        upload_button: 'submission_dissertation_file'))
      expect(page).to have_table('dissertation-file-table')
      expect(page).to have_css('th', text: 'Dissertation File (maximum size 1GB)')
      expect(page).to have_css('td', text: 'dissertation.pdf')
      expect(page).to have_no_button('Upload PDF')
    end
  end

  context 'when a dissertation file is not attached and required file type is set' do
    let(:submission) { create(:submission) }

    it 'renders the table with the upload link' do
      render_inline(described_class.new(file_type: 'dissertation',
                                        files: submission.dissertation_file,
                                        label: 'Dissertation File',
                                        required_file_type: 'PDF',
                                        upload_button: 'submission_dissertation_file'))
      expect(page).to have_table('dissertation-file-table')
      expect(page).to have_css('th', text: 'Dissertation File (maximum size 1GB)')
      expect(page).to have_button('Upload PDF')
    end
  end

  context 'when supplemental files are not attached' do
    let(:submission) { create(:submission) }

    it 'renders the table with the upload link' do
      render_inline(described_class.new(file_type: 'supplemental',
                                        files: submission.supplemental_files,
                                        label: 'Supplemental Files',
                                        upload_button: 'submission_supplemental_files'))
      expect(page).to have_table('supplemental-file-table')
      expect(page).to have_css('th', text: 'Supplemental Files (maximum size 1GB)')
      expect(page).to have_button('Upload supplemental file')
    end
  end

  context 'when supplemental files are attached' do
    let(:submission) do
      create(:submission, supplemental_files: [fixture_file_upload('supplemental_1.pdf', 'application/pdf')])
    end

    it 'renders the table with the upload link' do
      render_inline(described_class.new(file_type: 'supplemental',
                                        files: submission.supplemental_files,
                                        label: 'Supplemental Files',
                                        upload_button: 'submission_supplemental_files'))
      expect(page).to have_table('supplemental-file-table')
      expect(page).to have_css('th', text: 'Supplemental Files (maximum size 1GB)')
      expect(page).to have_css('td', text: 'supplemental_1.pdf')
      expect(page).to have_button('Upload more supplemental files')
    end
  end
end
