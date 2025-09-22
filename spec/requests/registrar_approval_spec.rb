# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Peoplesoft sends the registrar rejection message' do
  let(:data) do
    <<~XML
      <DISSERTATION>
        <dissertationid>#{dissertation_id}</dissertationid>
        <title>#{title}</title>
        <name>The Lorax</name>
        <sunetid>lorax</sunetid>
        <type>Dissertation</type>
        <degreeconfyr>2018</degreeconfyr>
        <readerapproval>Approved</readerapproval>
        <readercomment>Excellent job, infrastructure team</readercomment>
        <readeractiondttm>#{action_date_str} 09:44:49</readeractiondttm>
        <regapproval>Approved</regapproval>
        <regcomment>Congrats on finishing your dissertation</regcomment>
        <regactiondttm>#{action_date_str} 09:44:49</regactiondttm>
        <reader type="int">
          <sunetid>kme</sunetid>
          <name>Eisenhardt, Kathleen</name>
          <readerrole>Doct Dissert Advisor (AC)</readerrole>
          <finalreader>Yes</finalreader>
        </reader>
        <reader type="int">
          <sunetid>rkatila</sunetid>
          <name>Katila, Riitta</name>
          <readerrole>Doct Dissert Reader (AC)</readerrole>
          <finalreader>No</finalreader>
        </reader>
        <reader type="int">
          <sunetid>cee</sunetid>
          <name>Eesley, Charles</name>
          <readerrole>Doct Dissert Reader (AC)</readerrole>
          <finalreader>No</finalreader>
        </reader>
        <schoolname>School of Engineering</schoolname>
        <career code="GR">Graduate</career>
        <program code="MGTSC">Mgmt Sci &amp; Engineering</program>
        <plan code="MGTSC-PHD">Management Science and Engineering</plan>
        <degree>PHD</degree>
      </DISSERTATION>
    XML
  end
  let(:druid) { 'druid:789' }
  let(:dissertation_id) { '000123' }
  let(:submitted_at) { 2.days.ago }
  let(:title) { 'Registrar approved via PeopleSoft' }
  let(:action_date) { Time.zone.now.change(usec: 0) }
  let(:action_date_str) { action_date.in_time_zone(Rails.application.config.time_zone).strftime('%m/%d/%Y %T') }

  let!(:etd) do
    create(:submission,
           dissertation_id:,
           druid:,
           submitted_at:,
           title:,
           embargo: 'immediately')
  end

  context 'when the user has valid Basic Auth for dlss_admin' do
    let(:dlss_admin_credentials) do
      ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw)
    end

    context 'when passed in id is found' do
      before do
        allow(CreateStubMarcRecordJob).to receive(:perform_later)
        allow(CreateEmbargo).to receive(:call)
        allow(Dor::Services::Client).to receive(:objects).and_return(objects_client)
      end

      let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: model_response) }
      let(:model_response) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }

      it 'updates an existing Etd' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("#{druid} updated")
        etd.reload

        expect(etd.regapproval).to eq 'Approved'
        expect(etd.regcomment).to eq 'Congrats on finishing your dissertation'
        expect(etd.last_registrar_action_at).to eq action_date
        expect(etd.submitted_at).not_to be_nil
        expect(etd.submitted_to_registrar).to eq 'true'
        expect(CreateStubMarcRecordJob).to have_received(:perform_later).with(etd.druid).once
        expect(CreateEmbargo).to have_received(:call).with(etd.druid, etd.embargo_release_date).once
      end
    end
  end
end
