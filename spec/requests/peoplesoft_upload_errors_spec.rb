# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ETD creation errors from Peoplesoft' do
  let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }
  let(:context) { { xml: data } }

  before do
    allow(Honeybadger).to receive(:notify)
  end

  describe 'POST /etds' do
    context 'when no XML is provided' do
      let(:error_msg) do
        'Unable to process incoming dissertation: param is missing or the value is empty or invalid: DISSERTATION'
      end
      let(:data) do
        ''
      end

      it 'Notifies Honeybadger and returns an HTTP status of 400' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response).not_to be_successful
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include(error_msg)
        expect(Honeybadger).to have_received(:notify).with(error_msg, context:)
      end
    end

    context 'when no dissertation id is provided' do
      let(:error_msg) do
        'Unable to process incoming dissertation: param is missing or the value is empty or invalid: dissertationid'
      end
      let(:data) do
        <<~XML
          <DISSERTATION>
            <title>My etd</title>
          </DISSERTATION>
        XML
      end

      it 'Notifies Honeybadger and returns an HTTP status of 400' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response).not_to be_successful
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include(error_msg)
        expect(Honeybadger).to have_received(:notify).with(error_msg, context:)
      end
    end

    context 'when invlalid XML is provided' do
      let(:error_msg) { 'Unable to process incoming dissertation: Error occurred while parsing request parameters' }
      let(:data) do
        <<~XML
          <DISSERTATION>
            <dissertationid>000123</dissertationid>
            <title>Laser Path Optimization Strategies for\vLaser Powder Bed Fusion</title>
          </DISSERTATION>
        XML
      end

      it 'Notifies Honeybadger and returns an HTTP status of 400' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response).not_to be_successful
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include(error_msg)
        expect(Honeybadger).to have_received(:notify).with(error_msg, context:)
      end
    end

    context 'when no readers are passed in' do
      let(:error_msg) do
        'Unable to process incoming dissertation: param is missing or the value is empty or invalid: reader'
      end
      let(:data) do
        <<~XML
          <DISSERTATION>
            <dissertationid>000123</dissertationid>
            <title>My etd</title>
          </DISSERTATION>
        XML
      end

      it 'Notifies Honeybadger and returns an HTTP status of 400' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response).not_to be_successful
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include(error_msg)
        expect(Honeybadger).to have_received(:notify).with(error_msg, context:)
      end
    end
  end
end
