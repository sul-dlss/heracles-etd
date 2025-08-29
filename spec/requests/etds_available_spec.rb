# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ETDs available endpoint' do
  describe 'GET /etds' do
    it 'responds with OK' do
      get '/etds'
      expect(response).to be_successful
      expect(response.body).to eq('OK')
    end
  end
end
