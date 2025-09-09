# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Download supplemental file' do
  let(:submission) { create(:submission, :with_supplemental_files) }

  context 'when an unauthorized user' do
    before do
      sign_in('unauthorized_student')
    end

    it 'does not allow the user to download' do
      get supplemental_file_submission_path(submission, submission.supplemental_files.first)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when an authorized user' do
    before do
      sign_in(submission.sunetid)
    end

    it 'allows the user to download' do
      get supplemental_file_submission_path(submission, submission.supplemental_files.last)

      expect(response).to have_http_status(:ok)
      expect(response.header['Content-Disposition']).to include(submission.supplemental_files.last.filename.to_s)
    end
  end

  context 'when the supplemental file is missing' do
    before do
      sign_in(submission.sunetid)
    end

    it 'returns a not found status' do
      get supplemental_file_submission_path(submission, 10)

      expect(response).to have_http_status(:not_found)
    end
  end
end
