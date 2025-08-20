# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'View Admin Dashboard' do
  describe 'GET /admin' do
    context 'when the user is not authorized' do
      before do
        sign_in('testuser')
      end

      it 'returns unauthorized' do
        get '/admin'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
