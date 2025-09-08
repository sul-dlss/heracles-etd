# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::SupplementalFilesStepComponent, type: :component do
  let(:submission) { create(:submission, :with_advisors, :submitted) }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('h2', text: 'Upload supplemental files')

    row = page.all('#supplemental-files-table tbody tr')
    expect(row[0]).to have_link('supplémental_1.pdf')
    expect(row[0]).to have_no_button('Remove')
    expect(row[1]).to have_content('Supplemental file supplémental_1.pdf')
    expect(row[2]).to have_link('supplemental_2.pdf')
    expect(row[2]).to have_no_button('Remove')
    expect(row[3]).to have_content('Supplemental file supplemental_2.pdf')
  end
end
