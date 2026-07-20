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

    it 'does not treat a blank abstract as complete even if the completion flag is set' do
      patch submission_path(submission), params: {
        submission: { abstract: ' ', abstract_provided: true }
      }

      expect(response).to redirect_to(edit_submission_path(submission))
      expect(submission.reload.abstract_provided).to be true
      expect(SubmissionPresenter.step_done?(step: SubmissionPresenter::ABSTRACT_STEP, submission:)).to be false
    end

    it 'allows a blank abstract to be saved while the abstract step is incomplete' do
      patch submission_path(submission), params: {
        submission: { abstract: '', abstract_provided: false }
      }

      expect(response).to redirect_to(edit_submission_path(submission))
      expect(submission.reload).to have_attributes(abstract: '', abstract_provided: false)
    end

    it 'saves the abstract and completion flag in the same request' do
      patch submission_path(submission), params: {
        submission: { abstract: 'My completed abstract', abstract_provided: true }
      }

      expect(response).to redirect_to(edit_submission_path(submission))
      expect(submission.reload).to have_attributes(
        abstract: 'My completed abstract',
        abstract_provided: true
      )
    end
  end

  context 'when the student tries to edit a submitted submission' do
    let(:submission) { create(:submission, :submitted) }

    before do
      sign_in(submission.sunetid)
    end

    it 'redirects to the submission show page' do
      get edit_submission_path(submission)

      expect(response).to redirect_to(submission_path(submission))
    end
  end
end
