# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ETD creation errors from Peoplesoft' do
  let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }
  let(:context) { { xml: data } }
  let(:error_message) { 'Error processing dissertation input' }

  before do
    allow(Honeybadger).to receive(:notify)
  end

  describe 'POST /etds' do
    context 'when no XML is provided' do
      let(:data) { '' }

      it 'Notifies Honeybadger and returns an HTTP status of 400' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response).not_to be_successful
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include(error_message)
        expect(Honeybadger).to have_received(:notify).with(
          error_message,
          context:,
          error_message: 'key not found: :DISSERTATION',
          error_class: KeyError,
          backtrace: anything
        )
      end
    end

    context 'when no dissertation id is provided' do
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
        expect(response.body).to include(error_message)
        expect(Honeybadger).to have_received(:notify).with(
          error_message,
          context:,
          error_message: /dissertationid is missing in Hash input/,
          error_class: Dry::Struct::Error,
          backtrace: anything
        )
      end
    end

    context 'when invalid XML is provided' do
      let(:context) { { xml: data } }
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
        expect(response.body).to include(error_message)
        expect(Honeybadger).to have_received(:notify).with(
          error_message,
          context:,
          error_message: /Illegal character/,
          error_class: REXML::ParseException,
          backtrace: anything
        )
      end
    end

    context 'when no readers are passed in' do
      let(:data) do
        <<~XML
          <DISSERTATION>
            <dissertationid>000123</dissertationid>
            <title>My etd</title>
          </DISSERTATION>
        XML
      end

      it 'notifies Honeybadger and returns an HTTP status of 400' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response).not_to be_successful
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include(error_message)
        expect(Honeybadger).to have_received(:notify).with(
          error_message,
          context:,
          error_class: Dry::Struct::Error,
          error_message: /type is missing in Hash input/,
          backtrace: anything
        )
      end
    end
  end
end
