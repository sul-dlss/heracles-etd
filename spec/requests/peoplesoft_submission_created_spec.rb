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
  let(:druid) { 'druid:789' }
  let(:etd) { Submission.new(druid:, title: 'My etd', dissertation_id: '000123') }
  let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }

  before do
    allow(RegistrarDataImporter).to receive(:populate_submission).and_return(etd)
    allow(Honeybadger).to receive(:notify)
  end

  describe 'POST /etds' do
    context 'when the user has valid Basic Auth for dlss_admin' do
      let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }

      context 'when passed in id is not found' do
        let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: model_response) }
        let(:model_response) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }
        let(:dissertation_id) { '000123' }
        let(:params) do
          {
            'dissertationid' => dissertation_id,
            'title' => 'My etd',
            'reader' => [
              {
                'sunetid' => 'READ1',
                'prefix' => 'Mr.',
                'name' => 'Reader,First',
                'suffix' => 'Jr.',
                'type' => 'int',
                'univid' => '05358772',
                'readerrole' => 'Doct Dissert Advisor (AC)',
                'finalreader' => 'No'
              },
              {
                'sunetid' => ' ',
                'prefix' => 'Dr',
                'name' => 'Reader,Second',
                'suffix' => ' ',
                'type' => 'ext',
                'univid' => ' ',
                'readerrole' => 'External Reader',
                'finalreader' => 'No'
              }
            ]
          }
        end

        before do
          # allow(RetriableWorkflowCreationJob).to receive(:perform_later)
          allow(Dor::Services::Client).to receive(:objects).and_return(objects_client)
        end

        it 'creates a new Etd' do
          post '/etds',
               params: data,
               headers: { Authorization: dlss_admin_credentials,
                          'Content-Type': 'application/xml' }

          expect(response.body).to include('druid:789 created')
          expect(response).to have_http_status(:created)
          submission = Submission.find_by(dissertation_id:)
          expect(submission).not_to be_nil
          expect(submission.druid).to eq druid
          expect(submission.readers.count).to eq 2
        end
      end
    end
  end
end
