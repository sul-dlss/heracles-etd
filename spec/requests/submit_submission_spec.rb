# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Submitting a submission' do
  let(:submission) { create(:submission) }

  context 'with an unauthorized student' do
    before do
      sign_in('unauthorized_student')
    end

    it 'returns HTTP unauthorized' do
      post submit_submission_path(submission)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'with an authorized student' do
    let(:submission) { create(:submission, :submittable) }

    before do
      allow(SubmissionPoster).to receive(:call) do
        submission.prepare_to_submit!
      end

      sign_in(submission.sunetid)
    end

    it 'redirects to the submission show page and returns an HTTP OK' do
      post submit_submission_path(submission)
      expect(response).to redirect_to(submission_path(submission))
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end

    context 'when the abstract is blank despite being marked complete' do
      before do
        submission.update_columns(abstract: nil, abstract_provided: true) # rubocop:disable Rails/SkipsModelValidations
        allow(Honeybadger).to receive(:notify)
      end

      it 'reports the attempt and redirects without posting to the Registrar' do
        post submit_submission_path(submission)

        expect(response).to redirect_to(edit_submission_path(submission))
        expect(response).to have_http_status(:see_other)
        expect(SubmissionPoster).not_to have_received(:call)
        expect(submission.reload).not_to be_submitted
        expect(Honeybadger).to have_received(:notify).with(
          '[WARNING] Blocked attempt to submit an incomplete ETD to the Registrar',
          context: {
            submission:,
            abstract_provided: true,
            abstract_present: false,
            abstract_length: nil
          }
        )
      end
    end
  end
end
