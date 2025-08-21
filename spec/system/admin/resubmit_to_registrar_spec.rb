# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Re-post submission to Registrar' do
  let(:fake_client_id) { 'foo' }
  let(:fake_client_secret) { 'bar' }
  let(:fake_registrar_url) { 'http://registrar.example.edu' }
  let(:fake_token_url) { 'http://tokensrus.example.edu' }
  let(:fake_token) { { access_token: 'foobar', expires_in: 3600, token_type: 'Bearer' } }
  let(:submission) { create(:submission, :reader_approved, :submitted) }

  before do
    sign_in 'dlss_user', groups: [Settings.groups.dlss]
    allow(Settings.peoplesoft).to receive_messages(client_id: fake_client_id,
                                                   client_secret: fake_client_secret,
                                                   base_url: fake_registrar_url,
                                                   token_url: fake_token_url)

    stub_request(:post, "#{fake_registrar_url}#{PsRegistrarService::PEOPLESOFT_API_ENDPOINT}")
      .to_return(status: 200, body: '{"response":{"status":"SUCCESS","message":"Updated the Dissertation data"}}')
    stub_request(:post, fake_token_url)
      .to_return(status: 200, body: fake_token.to_json, headers: { 'Content-type' => 'application/json' })
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
