# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin - Reports' do
  let(:groups) { [] }
  let!(:report) { create(:report) }

  before { sign_in('joeschmoe', groups:) }

  describe 'GET /admin/reports' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get '/admin/reports'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get '/admin/reports'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'renders' do
        get '/admin/reports'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get '/admin/reports'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /admin/reports/new' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get '/admin/reports/new'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get '/admin/reports/new'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'returns unauthorized' do
        get '/admin/reports/new'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get '/admin/reports/new'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /admin/reports/:id' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get "/admin/reports/#{report.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get "/admin/reports/#{report.id}"

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'renders' do
        get "/admin/reports/#{report.id}"

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get "/admin/reports/#{report.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /admin/reports/:id/edit' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get "/admin/reports/#{report.id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get "/admin/reports/#{report.id}/edit"

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'returns unauthorized' do
        get "/admin/reports/#{report.id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get "/admin/reports/#{report.id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
