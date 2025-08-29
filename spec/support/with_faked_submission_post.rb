# frozen_string_literal: true

RSpec.shared_context 'with faked submission post' do
  let(:fake_registrar_url) { 'http://registrar.example.edu' }
  let(:fake_token_url) { 'http://tokensrus.example.edu' }
  let(:fake_token) { { access_token: 'foobar', expires_in: 3600, token_type: 'Bearer' } }

  before do
    allow(Settings.peoplesoft).to receive_messages(client_id: 'foo',
                                                   client_secret: 'bar',
                                                   base_url: fake_registrar_url,
                                                   token_url: fake_token_url)

    stub_request(:post, "#{fake_registrar_url}#{SubmissionPoster::API_ENDPOINT}")
      .to_return(status: 200, body: '{"response":{"status":"SUCCESS","message":"Updated the Dissertation data"}}',
                 headers: { 'Content-type' => 'application/json' })
    stub_request(:post, fake_token_url)
      .to_return(status: 200, body: fake_token.to_json, headers: { 'Content-type' => 'application/json' })
  end
end
