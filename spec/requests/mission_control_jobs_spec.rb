# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MissionControl jobs' do
  before { sign_in('janedoe', groups:) }

  describe 'GET /jobs' do
    context 'with admin user' do
      let(:groups) { [Settings.groups.dlss] }

      it 'renders the mission control interface' do
        get mission_control_jobs_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Mission control - Queues')
      end
    end

    context 'with non-admin user' do
      let(:groups) { [] }

      it 'prevents access' do
        get mission_control_jobs_path

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
