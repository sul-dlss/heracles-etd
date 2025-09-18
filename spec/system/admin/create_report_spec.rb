# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage reports on the admin dashboard' do
  let!(:etd) do
    create(:submission, :reader_approved, :submitted,
           last_registrar_action_at: 'Fri, 02 Feb 2024 10:03:00.000000000 UTC +00:00',
           druid: 'druid:mj151qw9093', name: 'Test Author', degreeconfyr: '2024', degree: 'Ph.D.',
           abstract: 'My abstract', schoolname: 'Doerr School of Sustainability')
  end
  let!(:older_etd) do
    create(:submission, :reader_approved, :submitted,
           last_registrar_action_at: 'Mon, 04 Dec 2023 13:03:00.000000000 UTC +00:00',
           druid: 'druid:bb111cc3333', name: 'Different Person', degreeconfyr: '2023', degree: 'Ph.D.',
           abstract: 'My abstract', schoolname: 'Doerr School of Sustainability')
  end

  before { sign_in('user', groups:) }

  context 'with a user in the DLSS group' do
    let(:groups) { [Settings.groups.dlss] }

    it 'shows the report, query results, and create report button' do
      visit '/admin/reports/new'
      fill_in 'Label', with: 'Winter 2024'
      fill_in 'Description', with: 'The first quarter of 2024'
      select '2024', from: 'report_start_date_1i'
      select 'January', from: 'report_start_date_2i'
      select '1', from: 'report_start_date_3i'
      select '00', from: 'report_start_date_4i'
      select '00', from: 'report_start_date_5i'
      select '2024', from: 'report_end_date_1i'
      select 'March', from: 'report_end_date_2i'
      select '31', from: 'report_end_date_3i'
      select '23', from: 'report_end_date_4i'
      select '59', from: 'report_end_date_5i'
      click_link_or_button 'Create Report'
      expect(page).to have_content('Winter 2024')

      visit '/admin/reports'
      click_link_or_button 'Winter 2024'
      expect(page).to have_content(etd.bare_druid)
      expect(page).to have_no_content(older_etd.bare_druid)
    end
  end
end
