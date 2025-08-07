# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit Submission' do
  let(:submission) { create(:submission) }

  it 'allows the user to edit a submission' do
    visit edit_submission_path(submission.dissertation_id)

    expect(page).to have_content('Welcome, Jane')
  end
end
