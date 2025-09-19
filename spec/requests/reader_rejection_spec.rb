# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Peoplesoft sends the reader rejection message' do
  let(:data) do
    registrar_xml(dissertation_id:, title:, readerapproval: rejection,
                  readercomment: 'Try harder next time, infrastructure team',
                  readeractiondttm: "#{action_date} 09:44:49")
  end
  let(:druid) { etd.druid }
  let(:dissertation_id) { '000123' }
  let(:submitted_at) { 2.days.ago }
  let(:title) { 'Reader Rejected via PeopleSoft' }
  let(:action_date) { Time.zone.today.strftime('%m/%d/%Y') } # must be after submit date.
  let(:rejection) { 'Rejected' }

  let(:etd) do
    create(:submission, dissertation_id:, submitted_at:, title:)
  end

  context 'when the user has valid Basic Auth for dlss_admin' do
    let(:dlss_admin_credentials) do
      ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw)
    end

    context 'when passed in id is found' do
      before do
        # allow(RetriableWorkflowUpdateJob).to receive(:perform_later)
        allow(Dor::Services::Client).to receive(:objects).and_return(objects_client)
      end

      let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: model_response) }
      let(:model_response) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }
      let(:last_reader_action_at) do
        DateTime.strptime("#{action_date} 09:44:49", '%m/%d/%Y %T').in_time_zone(Rails.application.config.time_zone)
      end

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
          expect(etd.last_reader_action_at).to eq last_reader_action_at
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
          expect(etd.last_reader_action_at).to eq last_reader_action_at
          expect(etd.submitted_at).to be_nil
          expect(etd.submitted_to_registrar).to eq 'false'
        end
      end
    end
  end
end
