# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::DissertationStepComponent, type: :component do
  let(:submission) { create(:submission, :with_advisors, :submitted) }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('h2', text: 'Upload your dissertation')
    expect(page).to have_css('p', text: 'Your dissertation must be a single PDF file.')

    row = page.find('#dissertation-file-table tbody tr')
    expect(row).to have_link('dissertation.pdf')
    expect(row).to have_no_button('Remove')
  end
end
