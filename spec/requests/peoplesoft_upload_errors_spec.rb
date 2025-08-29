# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ETD creation errors from Peoplesoft' do
  let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }

  describe 'POST /etds' do
    context 'when no XML is provided' do
      let(:error_msg) { 'Attempting to post a dissertation without any xml' }
      let(:data) do
        ''
      end

      it 'returns an HTTP status of 400' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response).not_to be_successful
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include(error_msg)
      end
    end

    context 'when invlalid XML is provided' do
      let(:error_msg) { 'Data posted from registrar is missing dissertationid -- cannot proceed' }
      let(:data) do
        <<~XML
          <Bogus>
            <totally>Bogus</totally>
          </Bogus>
        XML
      end

      it 'sends an alert email and returns an HTTP status of 500' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response).not_to be_successful
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include(error_msg)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq '[TEST] Error processing incoming dissertation from Peoplesoft'
        expect(ActionMailer::Base.deliveries.size).to eq(1)
        expect(Honeybadger).to have_received(:notify).with(error_msg, context: {})
      end
    end
  end
end
