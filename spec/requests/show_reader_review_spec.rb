# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Showing reader review page' do
  let(:submission) { create(:submission) }

  context 'when an unauthorized user' do
    before do
      sign_in('unauthorized_student')
    end

    it 'does not allow the user to view the reader review page' do
      get reader_review_submission_path(submission)

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
