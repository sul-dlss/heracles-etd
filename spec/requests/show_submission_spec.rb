# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /submissions/{SUBMISSION_ID}' do
  let(:submission) { create(:submission) }

  before { sign_in(submission.sunetid) }

  context 'with an authorized user and an unsubmitted submission' do
    it 'redirects the user to the edit view' do
      get submission_path(submission)

      expect(response).to have_http_status(:found)
      expect(response.location).to end_with(edit_submission_path(submission))
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Submit your dissertation or thesis')
    end
  end

  context 'when using the druid identifier' do
    let(:submission) { create(:submission, :submitted) }

    it 'renders the show view' do
      get submission_path(submission.druid)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Submit your dissertation or thesis')
    end
  end
end
