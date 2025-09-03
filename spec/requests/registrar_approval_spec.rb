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
        <readeractiondttm>#{action_date} 09:44:49</readeractiondttm>
        <regapproval>Approved</regapproval>
        <regcomment>Congrats on finishing your dissertation</regcomment>
        <regactiondttm>#{action_date} 09:44:49</regactiondttm>
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
  # action_date has to be after submit date.
  let(:action_date) { Time.zone.today.strftime('%d/%m/%Y') }

  let!(:etd) do
    create(:submission,
           dissertation_id:,
           druid:,
           submitted_at:,
           title:)
  end

  context 'when the user has valid Basic Auth for dlss_admin' do
    let(:dlss_admin_credentials) do
      ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw)
    end

    context 'when passed in id is found' do
      before do
        allow(CreateStubMarcRecordJob).to receive(:perform_later)
        allow(Dor::Services::Client).to receive(:objects).and_return(objects_client)
      end

      let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: model_response) }
      let(:model_response) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }

      it 'updates an existing Etd' do
        post '/etds',
             params: data,
             headers: { Authorization: dlss_admin_credentials,
                        'Content-Type': 'application/xml' }

        expect(response.body).to include("#{druid} updated")
        etd.reload

        expect(etd.regapproval).to eq 'Approved'
        expect(CreateStubMarcRecordJob).to have_received(:perform_later).with(etd.druid).once
      end
    end
  end
end
