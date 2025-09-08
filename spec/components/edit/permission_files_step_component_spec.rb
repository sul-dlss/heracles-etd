# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::PermissionFilesStepComponent, type: :component do
  let(:submission) { create(:submission, permissions_provided:) }
  let(:permissions_provided) { false }

  context 'without the permissions provided flag' do
    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Upload permissions')
      expect(page).to have_no_field('Upload permission files', type: 'file')
    end
  end

  context 'with the permissions provided flag' do
    let(:permissions_provided) { 'true' }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Upload permissions')
      expect(page).to have_field('Upload permission files', type: 'file')
    end
  end

  context 'with attached permission files' do
    let(:submission) { create(:submission, :with_permission_files) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Upload permissions')
      expect(page).to have_css('table#permission-files-table tr', count: 5)
      rows = page.all('table#permission-files-table tbody tr')
      cells = rows[0].all('td')
      expect(cells[3]).to have_button('Remove', type: 'submit')
      cells = rows[2].all('td')
      expect(cells[3]).to have_button('Remove', type: 'submit')
    end
  end
end
