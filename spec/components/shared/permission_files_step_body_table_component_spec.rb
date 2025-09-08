# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::PermissionFilesStepBodyTableComponent, type: :component do
  let(:submission) { create(:submission, :with_permission_files) }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('table#permission-files-table tr', count: 5)
    headers = page.all('table#permission-files-table thead th')
    expect(headers[0]).to have_content('Permission File')
    expect(headers[4]).to have_no_content('Remove')

    rows = page.all('table#permission-files-table tbody tr')
    cells = rows[0].all('th')
    expect(cells[0]).to have_link('permission_1.pdf')
    cells = rows[0].all('td')
    expect(cells[1]).to have_content('1.6 KB')
    expect(cells[2]).to have_css('time')
    expect(cells[3]).to have_no_button('Remove', type: 'submit')

    cells = rows[2].all('th')
    expect(cells[0]).to have_link('permission_2.pdf')
    cells = rows[2].all('td')
    expect(cells[1]).to have_content('1.6 KB')
    expect(cells[2]).to have_css('time')
    expect(cells[3]).to have_no_button('Remove', type: 'submit')
  end

  context 'when with_remove is true' do
    it 'renders the remove button' do
      render_inline(described_class.new(submission:, with_remove: true))

      headers = page.all('table#permission-files-table thead th')
      expect(headers[4]).to have_content('Remove')

      rows = page.all('table#permission-files-table tbody tr')
      cells = rows[0].all('td')
      expect(cells[3]).to have_button('Remove', type: 'submit')
      cells = rows[2].all('td')
      expect(cells[3]).to have_button('Remove', type: 'submit')
    end
  end
end
