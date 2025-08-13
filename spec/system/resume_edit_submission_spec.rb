# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resume editing Submission' do
  let(:submission) do
    create(:submission, citation_verified: 'true', abstract: 'Sample abstract', format_reviewed: 'true',
                        sulicense: 'true', cclicense: '3', embargo: '6 months')
  end

  before do
    sign_in(submission.sunetid)
  end

  it 'allows the user to edit a submission' do
    visit edit_submission_path(submission.dissertation_id)

    expect(page).to have_content("Welcome, #{submission.first_name}")

    expect(page).to have_css('.collapse.show', count: 1)
    expect(page).to have_css('.collapse:not(.show)', count: 6, visible: :hidden)

    # Step 7
    expect(page).to have_css('.alert-info',
                             text: 'You have completed sections 1-6')
    expect(page).to have_button('Review and submit')
  end
end
