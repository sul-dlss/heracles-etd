# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReaderReview::PermissionFilesComponent, type: :component do
  let(:submission) { create(:submission, :with_advisors, :submitted) }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('h2', text: 'Permission files')
    row = page.all('#permission-files-table tbody tr')
    expect(row[0]).to have_link('permission_1.pdf')
    expect(row[1]).to have_content('Permission file permission_1.pdf')
    expect(row[2]).to have_link('permission_2.pdf')
    expect(row[3]).to have_content('Permission file permission_2.pdf')
  end
end
