# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::DissertationStepBodyTableComponent, type: :component do
  let(:submission) { create(:submission, :with_dissertation_file) }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('table#dissertation-file-table tr', count: 2)
    headers = page.all('table#dissertation-file-table thead th')
    expect(headers[0]).to have_content('Dissertation File')
    expect(headers[4]).to have_no_content('Remove')

    cells = page.all('table#dissertation-file-table tbody tr td')
    expect(cells[0]).to have_link('dissertation.pdf')
    expect(cells[2]).to have_content('14.2 KB')
    expect(cells[3]).to have_css('time')
    expect(cells[4]).to have_no_button('Remove', type: 'submit')
  end

  context 'when with_remove is true' do
    it 'renders the remove button' do
      render_inline(described_class.new(submission:, with_remove: true))

      headers = page.all('table#dissertation-file-table thead th')
      expect(headers[4]).to have_content('Remove')

      cells = page.all('table#dissertation-file-table tbody tr td')
      expect(cells[4]).to have_button('Remove', type: 'submit')
    end
  end
end
