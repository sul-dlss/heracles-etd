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

    expect(page).to have_css('.alert-info', text: submission.dissertation_id)

    # Step 1
    expect(page).to have_css('h2', text: 'Citation details')
    # Step 2
    expect(page).to have_css('h2', text: 'Abstract')
    # Step 6
    expect(page).to have_css('h2', text: 'Copyright and license terms')
  end
end
