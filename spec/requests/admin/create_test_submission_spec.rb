# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a test submission' do
  let(:sunetid) { 'leland' }

  describe 'GET /admin/test_submission' do
    context 'when the user is not authorized' do
      before do
        sign_in(sunetid)
      end

      it 'returns unauthorized' do
        get '/admin/test_submission'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is DLSS staff' do
      before do
        sign_in(sunetid, groups: ['sdr:etds-sul-staff'])
      end

      it 'creates a test submission' do
        expect { get '/admin/test_submission' }.to change(Submission, :count).by(1)

        expect(response).to have_http_status(:redirect)

        submission = Submission.last
        expect(submission.sunetid).to eq(sunetid)
      end
    end
  end
end
