# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Download dissertation file' do
  let(:submission) { create(:submission, :with_augmented_dissertation_file) }

  context 'when an unauthorized user' do
    before do
      sign_in('unauthorized_student')
    end

    it 'does not allow the user to download' do
      get augmented_dissertation_file_submission_path(submission)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when an authorized user' do
    before do
      sign_in(submission.sunetid)
    end

    it 'allows the user to download' do
      get augmented_dissertation_file_submission_path(submission)

      expect(response).to have_http_status(:ok)
      expect(response.header['Content-Disposition']).to include('attachment; filename="dissertation.pdf"')
    end
  end

  context 'when the augmented dissertation file is missing' do
    before do
      submission.augmented_dissertation_file.purge
      sign_in(submission.sunetid)
    end

    it 'returns a not found status' do
      get augmented_dissertation_file_submission_path(submission)

      expect(response).to have_http_status(:not_found)
    end
  end
end
