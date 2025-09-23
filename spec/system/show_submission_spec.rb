# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show Submission', :rack_test do
  let(:submission) { create(:submission, :submitted) }
  let(:sunetid) { submission.sunetid }

  before do
    sign_in(sunetid)
  end

  context 'with the user is the author' do
    context 'with a submitted submission' do
      it 'shows the submitted submission' do
        visit submission_path(submission)

        expect(page).to have_css('header', text: 'Submit your dissertation or thesis')
        expect(page).to have_no_content('Read-only administrative view')

        expect(page).to have_content("Welcome, #{submission.first_name}")
        expect(page).to have_css('.banner-header', text: 'Submission successful.')

        expect(page).to have_css('h2', text: 'Progress')

        expect(page).to have_css('h2', text: 'Citation details')
        expect(page).to have_css('h2', text: 'Abstract')
        expect(page).to have_css('h2', text: 'Review your dissertation\'s formatting')
        expect(page).to have_css('h2', text: 'Apply copyright and license terms')
        expect(page).to have_css('h2', text: 'Upload your dissertation')
        expect(page).to have_link('dissertation.pdf')
        expect(page).to have_no_button('Remove')
        expect(page).to have_css('h2', text: 'Upload supplemental files')
        expect(page).to have_link('supplémental_1.pdf')
        expect(page).to have_content('Supplemental file supplémental_1.pdf')
        expect(page).to have_link('supplemental_2.pdf')
        expect(page).to have_content('Supplemental file supplemental_2.pdf')
        expect(page).to have_css('h2', text: 'Upload permissions')
        expect(page).to have_link('permission_1.pdf')
        expect(page).to have_content('Permission file permission_1.pdf')
        expect(page).to have_link('permission_2.pdf')
        expect(page).to have_content('Permission file permission_2.pdf')
        expect(page).to have_css('h2', text: 'Review and submit to Registrar')
      end
    end

    context 'with an approved submission' do
      let(:submission) { create(:submission, :submitted, :ready_for_cataloging) }

      it 'shows the approved submission' do
        visit submission_path(submission)

        expect(page).to have_css('header', text: 'Submit your dissertation or thesis')
        expect(page).to have_content("Welcome, #{submission.first_name}")
        expect(page).to have_css('.banner-header', text: 'Submission approved.')
      end
    end

    context 'when the user is an admin' do
      let(:groups) { Groups.new(groups: [Settings.groups.dlss]) }
      let(:sunetid) { 'admin' }

      before do
        allow(Groups).to receive(:new).and_return(groups)
      end

      it 'shows the submitted submission' do
        visit submission_path(submission)

        expect(page).to have_css('header', text: 'Submit your dissertation or thesis')
        expect(page).to have_css('.alert.alert-warning').once # there is an admin
        expect(page).to have_content('Read-only administrative view')
        expect(page).to have_content("Welcome, #{submission.first_name}")
        expect(page).to have_css('.banner-header', text: 'Submission successful.')
      end
    end
  end
end
