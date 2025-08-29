# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Preview of signature page' do
  let(:submission) { create(:submission) }

  context 'when authorized' do
    before do
      FileUtils.rm_rf('tmp/preview')

      sign_in(submission.sunetid)
    end

    it 'generates preview' do
      get "/submit/#{submission.dissertation_id}/preview"

      expect(response).to be_successful
      expect(response.body).to start_with("%PDF-1.5\n")
    end
  end

  context 'when unauthorized' do
    before do
      sign_in('unauthorized_student')
    end

    it 'sends an unauthorized message' do
      get "/submit/#{submission.dissertation_id}/preview"

      expect(response).to be_unauthorized
    end
  end
end
