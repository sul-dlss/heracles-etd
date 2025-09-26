# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Peoplesoft sends the reader approval message' do
  let(:data) do
    registrar_xml(dissertation_id:, title:, readerapproval: 'Approved',
                  readercomment: 'Excellent job, infrastructure team', readeractiondttm: action_date_str)
  end
  let(:druid) { etd.druid }
  let(:dissertation_id) { '000123' }
  let(:submitted_at) { 2.days.ago }
  let(:title) { 'Reader Approved via PeopleSoft' }
  let(:action_date) { Time.zone.now.change(usec: 0) } # action_date has to be after submit date.
  let(:action_date_str) { action_date.in_time_zone(Rails.application.config.time_zone).strftime('%m/%d/%Y %T') }
  let(:etd) { create(:submission, dissertation_id:, submitted_at:, title:) }
  let(:dlss_admin_credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw)
  end
  let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: model_response) }
  let(:model_response) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }

  before do
    allow(Dor::Services::Client).to receive(:objects).and_return(objects_client)
  end

  it 'updates an existing Etd' do
    post '/etds',
         params: data,
         headers: { Authorization: dlss_admin_credentials,
                    'Content-Type': 'application/xml' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("#{druid} updated")
    etd.reload

    expect(etd.readerapproval).to eq 'Approved'
    expect(etd.readercomment).to eq 'Excellent job, infrastructure team'
    expect(etd.last_reader_action_at).to eq action_date
    expect(etd.submitted_at).not_to be_nil
    expect(etd.submitted_to_registrar).to eq 'true'
  end
end
