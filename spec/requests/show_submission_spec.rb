# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Showing a submission' do
  let(:submission) { create(:submission) }

  context 'when a student is sent to the show view for their submission' do
    before do
      sign_in(submission.sunetid)
    end

    it 'redirects the user to the edit view' do
      get submission_path(submission)

      expect(response).to have_http_status(:found)
      expect(response.location).to end_with(edit_submission_path(submission))
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Submit your dissertation or thesis')
    end
  end
end
