# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Re-post submission to Registrar' do
  let(:submission) { create(:submission, :reader_approved, :submitted) }

  before do
    allow(SubmissionPoster).to receive(:call) do
      submission.prepare_to_submit!
    end

    sign_in 'dlss_user', groups: [Settings.groups.dlss]
  end

  it 'allows the user to re-post the submission' do
    visit admin_submission_path(submission.id)
    expect(page).to have_content(submission.title)
    expect(page).to have_link('Re-post to registrar')
    accept_alert do
      click_link('Re-post to registrar')
    end
    expect(page).to have_content('ETD successfully re-posted to Registrar')
    expect(page).to have_content(submission.title)
    expect(page).to have_content('Submission Details') # not in #index view
  end
end
