# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Re-post submission to Registrar' do
  let(:groups) { [Settings.groups.dlss] }
  let(:submission) { create(:submission, :reader_approved, :submitted) }

  before { sign_in('dlss_user', groups:) }

  context 'when the user is in the DLSS group' do
    before { allow(SubmissionPoster).to receive(:call) }

    it 'allows the submission to be re-posted' do
      post resubmit_to_registrar_admin_submission_path(submission)

      expect(response).to redirect_to(admin_submission_path(submission))
      expect(SubmissionPoster).to have_received(:call).with(submission:).once
    end
  end

  context 'when the user is not in the DLSS group' do
    let(:groups) { [] }

    it 'does not allow the submission to be re-posted' do
      post resubmit_to_registrar_admin_submission_path(submission)

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
