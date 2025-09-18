# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin - Submissions' do
  let(:groups) { [] }
  let!(:submission) { create(:submission) }

  before { sign_in('joeschmoe', groups:) }

  describe 'GET /admin/submissions' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get '/admin/submissions'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get '/admin/submissions'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'renders' do
        get '/admin/submissions'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get '/admin/submissions'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /admin/submissions/new' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get '/admin/submissions/new'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get '/admin/submissions/new'

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'returns unauthorized' do
        get '/admin/submissions/new'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get '/admin/submissions/new'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /admin/submissions/:id' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get "/admin/submissions/#{submission.dissertation_id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders' do
        get "/admin/submissions/#{submission.dissertation_id}"

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'returns unauthorized' do
        get "/admin/submissions/#{submission.dissertation_id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get "/admin/submissions/#{submission.dissertation_id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /admin/submissions/:id/edit' do
    context 'with a user in no recognized groups' do
      it 'returns unauthorized' do
        get "/admin/submissions/#{submission.dissertation_id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the DLSS group and a submitted submission' do
      let(:groups) { [Settings.groups.dlss] }
      let!(:submission) { create(:submission, :submitted) }

      it 'renders' do
        get "/admin/submissions/#{submission.dissertation_id}/edit"

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with a user in the DLSS group and an unsubmitted submission' do
      let(:groups) { [Settings.groups.dlss] }

      it 'returns unauthorized' do
        get "/admin/submissions/#{submission.dissertation_id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the reports group' do
      let(:groups) { [Settings.groups.reports] }

      it 'returns unauthorized' do
        get "/admin/submissions/#{submission.dissertation_id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with a user in the registrar group' do
      let(:groups) { [Settings.groups.registrar] }

      it 'returns unauthorized' do
        get "/admin/submissions/#{submission.dissertation_id}/edit"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
