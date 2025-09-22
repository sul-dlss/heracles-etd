# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Peoplesoft sends the reader rejection message' do
  let(:data) do
    <<~XML
      <DISSERTATION>
        <dissertationid>#{dissertation_id}</dissertationid>
        <title>#{title}</title>
        <name>The Lorax</name>
        <sunetid>lorax</sunetid>
        <type>Dissertation</type>
        <degreeconfyr>2018</degreeconfyr>
        <readerapproval>#{rejection}</readerapproval>
        <readercomment>Try harder next time, infrastructure team</readercomment>
        <readeractiondttm>#{action_date_str}</readeractiondttm>
        <regapproval></regapproval>
        <regcomment></regcomment>
        <regactiondttm></regactiondttm>
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
  let(:title) { 'Reader Rejected via PeopleSoft' }
  # action_date has to be after submit date.
  let(:action_date) { Time.zone.now.change(usec: 0) }
  let(:action_date_str) { action_date.in_time_zone(Rails.application.config.time_zone).strftime('%m/%d/%Y %T') }
  let(:rejection) { 'Rejected' }

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
        allow(Dor::Services::Client).to receive(:objects).and_return(objects_client)
      end

      let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: model_response) }
      let(:model_response) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }

      context 'with a basic reader rejection' do
        it 'updates an existing Etd' do
          post '/etds',
               params: data,
               headers: { Authorization: dlss_admin_credentials,
                          'Content-Type': 'application/xml' }

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("#{druid} updated")
          etd.reload

          expect(etd.readerapproval).to eq 'Rejected'
          expect(etd.readercomment).to eq 'Try harder next time, infrastructure team'
          expect(etd.last_reader_action_at).to eq action_date
          expect(etd.submitted_at).to be_nil
          expect(etd.submitted_to_registrar).to eq 'false'
        end
      end

      context 'with a rejection with modification' do
        let(:rejection) { 'Reject with modification' }

        it 'updates an existing Etd' do
          post '/etds',
               params: data,
               headers: { Authorization: dlss_admin_credentials,
                          'Content-Type': 'application/xml' }

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("#{druid} updated")
          etd.reload

          expect(etd.readerapproval).to eq 'Reject with modification'
          expect(etd.readercomment).to eq 'Try harder next time, infrastructure team'
          expect(etd.last_reader_action_at).to eq action_date
          expect(etd.submitted_at).to be_nil
          expect(etd.submitted_to_registrar).to eq 'false'
        end
      end
    end
  end
end
