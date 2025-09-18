# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Dashboard' do
  describe 'GET /admin' do
    let(:groups) { [] }

    before { sign_in('joeschmoe', groups:) }

    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get '/admin'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get '/admin'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'renders' do
        get '/admin'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get '/admin'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
