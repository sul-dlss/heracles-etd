# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ETDs created from Peoplesoft upload' do
  let(:params) { registrar_xml }
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
         params:,
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

  context 'when only a single reader is provided' do
    let(:params) do
      <<~XML
        <DISSERTATION>
          <dissertationid>000123</dissertationid>
          <title>My etd</title>
          <type>Dissertation</type>
          <sunetid>student1</sunetid>
          <vpname>Provost McProvostpants</vpname>
          <degreeconfyr>2025</degreeconfyr>
          <schoolname>Graduate School of Education</schoolname>
          <readerapproval></readerapproval>
          <readercomment></readercomment>
          <readeractiondttm></readeractiondttm>
          <regapproval></regapproval>
          <regcomment></regcomment>
          <regactiondttm></regactiondttm>
          <documentaccess>No</documentaccess>
          <univid>12345678</univid>
          <prefix></prefix>
          <name>Student, I. M.</name>
          <suffix></suffix>
          <career code="GR">Graduate</career>
          <program code="EDUC">Education</program>
          <plan code="ED-PHD">Education</plan>
          <degree>PHD</degree>
          <term>1258</term>
          <sub deadline="2025-09-03"/>
          <subplan code="EDCTEPHD5">Science, Engineering &amp; Tech Ed</subplan>
          <reader>
            <sunetid>READ1</sunetid>
            <prefix>Mr.</prefix>
            <name>Reader,First</name>
            <suffix>Jr.</suffix>
            <type>int</type>
            <univid>987654321</univid>
            <readerrole>Doct Dissert Advisor (AC)</readerrole>
            <finalreader>Yes</finalreader>
          </reader>
        </DISSERTATION>
      XML
    end

    it 'creates a new Etd' do
      post '/etds', params:, headers: {
        Authorization: dlss_admin_credentials,
        'Content-Type': 'application/xml'
      }

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
