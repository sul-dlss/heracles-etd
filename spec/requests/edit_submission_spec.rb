# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Editing a submission' do
  let(:submission) { create(:submission) }

  context 'when an unauthorized student tried to edit a submission' do
    before do
      sign_in('unauthorized_student')
    end

    it 'does not allow the student to edit the submission' do
      get edit_submission_path(submission.dissertation_id)

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
