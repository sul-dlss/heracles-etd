# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Editing a submission' do
  let(:submission) { create(:submission) }

  context 'when an unauthorized student tries to edit a submission' do
    before do
      sign_in('unauthorized_student')
    end

    it 'does not allow the student to edit the submission' do
      get edit_submission_path(submission)

      expect(response).to have_http_status(:unauthorized)
      expect(submission.reload.orcid).to be_nil
    end
  end

  context 'when the student tries to edit a submission' do
    before do
      sign_in(submission.sunetid)
    end

    it 'allows the student to edit the submission' do
      get edit_submission_path(submission)

      expect(response).to have_http_status(:ok)
      expect(submission.reload.orcid).to eq(TEST_ORCID)
    end
  end
end
