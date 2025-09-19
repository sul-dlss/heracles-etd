# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ETDs created from Peoplesoft upload' do
  let(:data) { registrar_xml }
  let(:druid) { 'druid:789' }
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

  describe 'POST /etds' do
    it 'creates a new Etd' do
      post '/etds', params: data, headers: {
        Authorization: dlss_admin_credentials,
        'Content-Type': 'application/xml'
      }

      expect(response).to have_http_status(:created)
      expect(response.body).to include('druid:789 created')

      submission = Submission.find_by(dissertation_id:)
      expect(submission).not_to be_nil
      expect(submission.druid).to eq druid
      expect(submission.readers.count).to eq 2
      expect(object_client).to have_received(:workflow).with('registrationWF')
      expect(workflow_client).to have_received(:create).with(version: 1)
    end
  end
end
