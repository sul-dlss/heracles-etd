# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legacy routes' do
  before do
    sign_in('adminuser', groups: [Settings.groups.dlss])
  end

  describe 'GET /view/:id' do
    let(:submission) { create(:submission, :submitted, :with_readers) }

    it 'redirects to submission#reader_review' do
      get legacy_view_show_path(submission)

      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to end_with(reader_review_submission_path(submission))
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Faculty guide for reviewing theses and dissertations')
    end
  end

  describe 'GET /submit/:id' do
    let(:submission) { create(:submission, :submitted) }

    it 'redirects to submission#show' do
      get legacy_submit_show_path(submission)

      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to end_with(submission_path(submission))
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('View your dissertation or thesis')
    end
  end

  describe 'GET /submit/:id/edit' do
    let(:submission) { create(:submission) }

    before do
      sign_in(submission.sunetid)
    end

    it 'redirects to submission#edit' do
      get legacy_submit_edit_path(submission)

      expect(response).to have_http_status(:moved_permanently)
      expect(response.location).to end_with(edit_submission_path(submission))
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Submit your dissertation or thesis')
    end
  end
end
