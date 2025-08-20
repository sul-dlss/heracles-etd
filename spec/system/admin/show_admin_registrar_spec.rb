# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show admin interface as registrar user' do
  let!(:submission) { create(:submission, :with_readers, :submitted) }
  let(:reader) { submission.readers.first }

  before do
    sign_in 'registrar_user', groups: [Settings.groups.registrar]
  end

  it 'allows registrar user to view admin' do
    visit '/admin'

    expect(page).to have_css('h2', text: 'Dashboard')

    click_link_or_button 'Quarterly Reports'
    expect(page).to have_no_link('New Report')
    expect(page).to have_link('Fall, 2009')

    expect(page).to have_no_link('Readers')

    click_link_or_button 'Submissions'
    expect(page).to have_css('.col-title', text: submission.title)
    click_link_or_button(submission.id)

    expect(page).to have_css('.col-name', text: reader.name)
    expect(page).to have_css('.col-file_name', text: 'dissertation.pdf')
    expect(page).to have_no_link('Edit Submission')
  end
end
