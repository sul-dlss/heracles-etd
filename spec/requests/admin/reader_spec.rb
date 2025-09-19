# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin - Readers' do
  let(:groups) { [] }
  let!(:reader) { create(:reader) }

  before { sign_in('joeschmoe', groups:) }

  describe 'GET /admin/readers' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get '/admin/readers'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get '/admin/readers'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'returns unauthorized' do
        get '/admin/readers'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get '/admin/readers'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /admin/readers/new' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get '/admin/readers/new'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get '/admin/readers/new'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'returns unauthorized' do
        get '/admin/readers/new'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get '/admin/readers/new'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /admin/readers/:id' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get "/admin/readers/#{reader.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get "/admin/readers/#{reader.id}"

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'returns unauthorized' do
        get "/admin/readers/#{reader.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get "/admin/readers/#{reader.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /admin/readers/:id/edit' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get "/admin/readers/#{reader.id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get "/admin/readers/#{reader.id}/edit"

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'returns unauthorized' do
        get "/admin/readers/#{reader.id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get "/admin/readers/#{reader.id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
