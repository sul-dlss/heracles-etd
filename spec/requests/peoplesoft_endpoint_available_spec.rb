# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Peoplesoft endpoint is available' do
  let(:dlss_admin_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials(Settings.dlss_admin, Settings.dlss_admin_pw) }

  describe 'GET /etds' do
    it 'responds with OK' do
      get '/etds',
          headers: { Authorization: dlss_admin_credentials }

      expect(response).to be_successful
      expect(response.body).to eq('OK')
    end
  end
end
