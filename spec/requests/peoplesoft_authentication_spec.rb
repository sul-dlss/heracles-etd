# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ETDs created from Peoplesoft upload' do
  let(:data) do
    <<~XML
      <DISSERTATION>
        <reader>
          <sunetid>READ1</sunetid>
          <prefix>Mr.</prefix>
          <name>Reader,First</name>
          <suffix>Jr.</suffix>
          <type>int</type>
          <univid>05358772</univid>
          <readerrole>Doct Dissert Advisor (AC)</readerrole>
          <finalreader>No</finalreader>
        </reader>
        <reader>
          <sunetid> </sunetid>
          <prefix>Dr</prefix>
          <name>Reader,Second</name>
          <suffix> </suffix>
          <type>ext</type>
          <univid> </univid>
          <readerrole>External Reader</readerrole>
          <finalreader>No</finalreader>
        </reader>
        <dissertationid>000123</dissertationid>
        <title>My etd</title>
        <type>Dissertation</type>
        <sunetid>student1</sunetid>
      </DISSERTATION>
    XML
  end
  let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }
  let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: model_response) }
  let(:model_response) { instance_double(Cocina::Models::DRO, externalIdentifier: 'druid:bc123df4567') }

  before do
    allow(Honeybadger.config).to receive(:[]).and_call_original
    allow(Dor::Services::Client).to receive(:objects).and_return(objects_client)
  end

  describe 'POST /etds' do
    %w[qa stage development test].each do |env|
      context "when env is '#{env}'" do
        before do
          allow(Honeybadger.config).to receive(:[]).with(:env).and_return(env)
        end

        context 'with HTTP Basic auth' do
          it 'authenticates the request' do
            post '/etds',
                 params: data,
                 headers: { Authorization: dlss_admin_credentials,
                            'Content-Type': 'application/xml' }

            expect(response).to have_http_status(:created)
          end
        end

        context 'with IP-based auth' do
          before do
            allow(Resolv).to receive(:getname).and_raise(Resolv::ResolvError)
            allow(Settings).to receive(:ps_ips).and_return('127.0.0.1')
          end

          it 'fails to authenticate the request' do
            post '/etds',
                 params: data,
                 headers: { 'Content-Type': 'application/xml' }

            expect(response).to have_http_status(:unauthorized)
          end
        end

        context 'with host-based auth' do
          before do
            allow(Resolv).to receive(:getname).and_return(Settings.ps_servers.first)
          end

          it 'fails to authenticate the request' do
            post '/etds',
                 params: data,
                 headers: { 'Content-Type': 'application/xml' }

            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end

    %w[uat prod].each do |env|
      context "when env is '#{env}'" do
        before do
          allow(Honeybadger.config).to receive(:[]).with(:env).and_return(env)
        end

        context 'with HTTP Basic auth' do
          it 'fails to authenticate the request' do
            post '/etds',
                 params: data,
                 headers: { Authorization: dlss_admin_credentials,
                            'Content-Type': 'application/xml' }

            expect(response).to have_http_status(:unauthorized)
          end
        end

        context 'with host-based auth' do
          before do
            allow(Resolv).to receive(:getname).and_return(Settings.ps_servers.first)
          end

          it 'authenticates the request' do
            post '/etds',
                 params: data,
                 headers: { 'Content-Type': 'application/xml' }

            expect(response).to have_http_status(:created)
          end
        end

        context 'with IP-based auth' do
          before do
            allow(Resolv).to receive(:getname).and_raise(Resolv::ResolvError)
            allow(Settings).to receive(:ps_ips).and_return('127.0.0.1')
          end

          it 'authenticates the request' do
            post '/etds',
                 params: data,
                 headers: { 'Content-Type': 'application/xml' }

            expect(response).to have_http_status(:created)
          end
        end
      end
    end
  end
end
