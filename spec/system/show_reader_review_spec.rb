# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show Submission', :rack_test do
  let(:submission) { create(:submission, :submitted, :with_readers) }
  let(:reader) { submission.readers.first }

  before do
    sign_in(reader.sunetid)
  end

  it 'allows the user to view the submission' do
    visit reader_review_submission_path(submission.dissertation_id)

    expect(page).to have_css('header', text: 'View dissertation or thesis')
    expect(page).to have_css('.alert-info', text: submission.dissertation_id)

    expect(page).to have_css('h2', text: 'Citation details')
    expect(page).to have_css('h2', text: 'Abstract')
    expect(page).to have_css('h2', text: 'Copyright and license terms')
    expect(page).to have_css('h2', text: 'Dissertation files')
    expect(page).to have_link('dissertation.pdf')
    expect(page).to have_css('h2', text: 'Supplemental files')
    expect(page).to have_link('supplemental_1.pdf')
    expect(page).to have_content('Supplemental file supplemental_1.pdf')
    expect(page).to have_link('supplemental_2.pdf')
    expect(page).to have_content('Supplemental file supplemental_2.pdf')
    expect(page).to have_css('h2', text: 'Permission files')
    expect(page).to have_link('permission_1.pdf')
    expect(page).to have_link('permission_2.pdf')
  end
end
