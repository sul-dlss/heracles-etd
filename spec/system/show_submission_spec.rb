# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show Submission', :rack_test do
  let(:submission) { create(:submission, :submitted) }

  before do
    sign_in(submission.sunetid)
  end

  it 'allows the user to edit a submission' do
    visit submission_path(submission.dissertation_id)

    expect(page).to have_css('header', text: 'Review and submit your dissertation')
    expect(page).to have_content("Welcome, #{submission.first_name}")

    expect(page).to have_css('h2', text: 'Progress')

    # Step 1
    expect(page).to have_css('h2', text: 'Citation details')
    # Step 2
    expect(page).to have_css('h2', text: 'Abstract')
    # Step 3
    expect(page).to have_css('h2', text: 'Review your dissertation\'s formatting')
    # Step 7
    expect(page).to have_css('h2', text: 'Apply copyright and license terms')
    # Step 8
    expect(page).to have_css('h2', text: 'Review and submit to Registrar')
  end
end
