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
        <dissertationid>#{dissertation_id}</dissertationid>
        <title>My etd</title>
        <type>Dissertation</type>
        <sunetid>student1</sunetid>
      </DISSERTATION>
    XML
  end
  let(:druid) { 'druid:bc789df8765' }
  let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }
  let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: model_response) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, workflow: workflow_client) }
  let(:workflow_client) { instance_double(Dor::Services::Client::ObjectWorkflow, create: true) }
  let(:model_response) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }
  let(:dissertation_id) { '000123' }

  before do
    allow(Honeybadger).to receive(:notify)
    allow(Dor::Services::Client).to receive_messages(objects: objects_client, object: object_client)
  end

  it 'creates a new Etd' do
    post '/etds',
         params: data,
         headers: { Authorization: dlss_admin_credentials,
                    'Content-Type': 'application/xml' }

    expect(response).to have_http_status(:created)
    expect(response.body).to include('druid:bc789df8765 created')

    submission = Submission.find_by(dissertation_id:)
    expect(submission).not_to be_nil
    expect(submission.druid).to eq druid
    expect(submission.readers.count).to eq 2
    expect(object_client).to have_received(:workflow).with('registrationWF')
    expect(workflow_client).to have_received(:create).with(version: 1)
  end

  context 'when student creates a submission then edits the title' do
    let(:data_with_new_title) do
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
          <dissertationid>#{dissertation_id}</dissertationid>
          <title>My changed etd</title>
          <type>Dissertation</type>
          <sunetid>student1</sunetid>
        </DISSERTATION>
      XML
    end

    it 'creates a new Etd' do
      post '/etds',
           params: data,
           headers: { Authorization: dlss_admin_credentials,
                      'Content-Type': 'application/xml' }

      expect(response).to have_http_status(:created)
      expect(response.body).to include('druid:bc789df8765 created')

      post '/etds',
           params: data_with_new_title,
           headers: { Authorization: dlss_admin_credentials,
                      'Content-Type': 'application/xml' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('druid:bc789df8765 updated')
    end
  end

  context 'when only a single reader is provided' do
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
          <dissertationid>000123</dissertationid>
          <title>My etd</title>
          <type>Dissertation</type>
          <sunetid>student1</sunetid>
        </DISSERTATION>
      XML
    end

    it 'creates a new Etd' do
      post '/etds',
           params: data,
           headers: { Authorization: dlss_admin_credentials,
                      'Content-Type': 'application/xml' }

      expect(response).to have_http_status(:created)
      expect(response.body).to include('druid:bc789df8765 created')

      submission = Submission.find_by(dissertation_id:)
      expect(submission).not_to be_nil
      expect(submission.druid).to eq druid
      expect(submission.readers.count).to eq 1
      expect(object_client).to have_received(:workflow).with('registrationWF')
      expect(workflow_client).to have_received(:create).with(version: 1)
    end
  end
end
