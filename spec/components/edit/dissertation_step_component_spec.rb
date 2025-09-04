# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::DissertationStepComponent, type: :component do
  context 'without an attached dissertation file' do
    let(:submission) { create(:submission) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Upload your dissertation')
      expect(page).to have_field('Upload PDF', type: 'file')
    end
  end

  context 'with an attached dissertation file' do
    let(:submission) { create(:submission, :with_dissertation_file) }

    it 'renders the component' do
      render_inline(described_class.new(submission:))

      expect(page).to have_css('h2', text: 'Upload your dissertation')
      expect(page).to have_css('table#dissertation-file-table tr', count: 2)
      cells = page.all('table#dissertation-file-table tbody tr td')
      expect(cells[3]).to have_button('Remove', type: 'submit')
    end
  end
end
