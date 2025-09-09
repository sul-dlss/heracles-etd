# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::PermissionFilesStepComponent, type: :component do
  context 'when there are no permission files' do
    let(:submission) { create(:submission) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Upload permissions')
      expect(page).to have_content('My dissertation does not include permission files.')
    end
  end

  context 'when there are permission files' do
    let(:submission) { create(:submission, :with_advisors, :submitted) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Upload permissions')

      row = page.all('#permission-files-table tbody tr')
      expect(row[0]).to have_link('permission_1.pdf')
      expect(row[0]).to have_no_button('Remove')
      expect(row[1]).to have_content('Permission file permission_1.pdf')
      expect(row[2]).to have_link('permission_2.pdf')
      expect(row[2]).to have_no_button('Remove')
      expect(row[3]).to have_content('Permission file permission_2.pdf')
    end
  end
end
