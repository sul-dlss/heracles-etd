# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegisterService do
  subject(:register) { described_class.register(submission:) }

  let(:submission) { instance_double(Submission, dissertation_id: '000123', title: 'My dissertation') }
  let(:druid) { 'druid:bc123df4567' }
  let(:registered_dro) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }
  let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: registered_dro) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, workflow: workflow_client) }
  let(:workflow_client) { instance_double(Dor::Services::Client::ObjectWorkflow, create: true) }

  before do
    allow(Dor::Services::Client).to receive_messages(objects: objects_client, object: object_client)
  end

  it 'registers the ETD as a document and starts the registration workflow' do
    expect(register).to eq(registered_dro)

    expect(objects_client).to have_received(:register) do |params:|
      expect(params.type).to eq(Cocina::Models::ObjectType.document)
      expect(params.description.title.first.value).to eq('My dissertation')
      expect(params.identification.sourceId).to eq('dissertation:000123')
      expect(params.administrative.hasAdminPolicy).to eq(Settings.etd_apo)
    end
    expect(Dor::Services::Client).to have_received(:object).with(druid)
    expect(object_client).to have_received(:workflow).with('registrationWF')
    expect(workflow_client).to have_received(:create).with(version: 1)
  end
end
