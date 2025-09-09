# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Download permission file' do
  let(:submission) { create(:submission, :with_permission_files) }

  context 'when an unauthorized user' do
    before do
      sign_in('unauthorized_student')
    end

    it 'does not allow the user to download' do
      get permission_file_submission_path(submission, submission.permission_files.first)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when an authorized user' do
    before do
      sign_in(submission.sunetid)
    end

    it 'allows the user to download' do
      get permission_file_submission_path(submission, submission.permission_files.first)

      expect(response).to have_http_status(:ok)
      expect(response.header['Content-Disposition']).to include(submission.permission_files.first.filename.to_s)
    end
  end

  context 'when the permission file is missing' do
    before do
      sign_in(submission.sunetid)
    end

    it 'returns a not found status' do
      get permission_file_submission_path(submission, 10)

      expect(response).to have_http_status(:not_found)
    end
  end
end
