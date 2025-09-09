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

    it 'returns an HTTP 200 & sets the ORCID' do
      get edit_submission_path(submission)

      expect(response).to have_http_status(:ok)
      expect(submission.reload.orcid).to eq(TEST_ORCID)
    end

    context 'when the submission already has an ORCID' do
      let(:submission) { create(:submission, :with_orcid) }

      it 'returns an HTTP 200 & does not reset the ORCID' do
        get edit_submission_path(submission)

        expect(response).to have_http_status(:ok)
        expect(submission.reload.orcid).to eq('0000-0002-1825-0097')
      end
    end
  end
end
