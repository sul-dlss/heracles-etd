# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Download dissertation file' do
  let(:submission) { create(:submission, :with_dissertation_file) }

  context 'when an unauthorized user' do
    before do
      sign_in('unauthorized_student')
    end

    it 'does not allow the user to download' do
      get dissertation_file_submission_path(submission)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when an authorized user' do
    before do
      sign_in(submission.sunetid)
    end

    it 'allows the user to download' do
      get dissertation_file_submission_path(submission)

      expect(response).to have_http_status(:ok)
      expect(response.header['Content-Disposition']).to include(submission.dissertation_file.filename.to_s)
    end
  end

  context 'when the dissertation file is missing' do
    before do
      submission.dissertation_file.purge
      sign_in(submission.sunetid)
    end

    it 'returns a not found status' do
      get dissertation_file_submission_path(submission)

      expect(response).to have_http_status(:not_found)
    end
  end
end
