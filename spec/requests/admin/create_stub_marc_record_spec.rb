# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create stub MARC record' do
  let(:groups) { [Settings.groups.dlss] }

  before { sign_in('dlss_user', groups:) }

  context 'when the submission is ready for cataloging and has no stub record' do
    let(:submission) { create(:submission, :ready_for_cataloging) }

    before { allow(CreateStubMarcRecordJob).to receive(:perform_later) }

    it 'shows the action and queues the job' do
      get admin_submission_path(submission)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Create stub MARC record')

      post create_stub_marc_record_admin_submission_path(submission)

      expect(response).to redirect_to(admin_submission_path(submission))
      expect(CreateStubMarcRecordJob).to have_received(:perform_later).with(submission.druid).once
    end
  end

  context 'when the submission is not ready for cataloging' do
    let(:submission) { create(:submission, :submitted) }

    before { allow(CreateStubMarcRecordJob).to receive(:perform_later) }

    it 'hides the action and does not queue the job' do
      get admin_submission_path(submission)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('Create stub MARC record')

      post create_stub_marc_record_admin_submission_path(submission)

      expect(response).to redirect_to(admin_submission_path(submission))
      expect(CreateStubMarcRecordJob).not_to have_received(:perform_later)
    end
  end

  context 'when the stub record has already been written' do
    let(:submission) { create(:submission, :stub_record_in_ils) }

    before { allow(CreateStubMarcRecordJob).to receive(:perform_later) }

    it 'hides the action and does not queue the job' do
      get admin_submission_path(submission)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('Create stub MARC record')

      post create_stub_marc_record_admin_submission_path(submission)

      expect(response).to redirect_to(admin_submission_path(submission))
      expect(CreateStubMarcRecordJob).not_to have_received(:perform_later)
    end
  end

  context 'when the user is not in the DLSS group' do
    let(:groups) { [] }
    let(:submission) { create(:submission, :ready_for_cataloging) }

    it 'does not allow the job to be queued' do
      post create_stub_marc_record_admin_submission_path(submission)

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
