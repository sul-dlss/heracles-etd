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
      </DISSERTATION>
    XML
  end
  let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }

  describe 'POST /etds' do
    context 'when the user has valid Basic Auth for dlss_admin' do
      let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }

      context 'when passed in id is not found' do
        # before do
        #   allow(RetriableWorkflowCreationJob).to receive(:perform_later)
        #   allow(Dor::Services::Client).to receive(:objects).and_return(objects_client)
        # end

        # let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: model_response) }
        # let(:model_response) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }

        it 'creates a new Etd' do
          allow(Submission).to receive(:find_by).with(dissertation_id: '000123').and_return(nil)

          post '/etds',
               params: data,
               headers: { Authorization: dlss_admin_credentials,
                          'Content-Type': 'application/xml' }

          expect(response.body).to include('druid:789 created')
          # expect(RegistrarDataImporter).to have_received(:populate_submission)
          #   .with({ 'dissertationid' => '000123', 'title' => 'My etd' },
          #         submission: Submission,
          #         readers: [{ 'finalreader' => 'No',
          #                     'name' => 'Reader,First',
          #                     'position' => 1,
          #                     'prefix' => 'Mr.',
          #                     'readerrole' => 'Doct Dissert Advisor (AC)',
          #                     'suffix' => 'Jr.',
          #                     'sunetid' => 'READ1',
          #                     'type' => 'int',
          #                     'univid' => '05358772' },
          #                   { 'finalreader' => 'No',
          #                     'name' => 'Reader,Second',
          #                     'position' => 2,
          #                     'prefix' => 'Dr',
          #                     'readerrole' => 'External Reader',
          #                     'suffix' => nil,
          #                     'sunetid' => nil,
          #                     'type' => 'ext',
          #                     'univid' => nil }])

          # expect(RetriableWorkflowCreationJob).to have_received(:perform_later).with(druid)
        end
      end
    end
  end
end
