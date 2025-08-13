# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit Submission' do
  let(:submission) { create(:submission) }

  describe 'when an unauthorized student tried to edit a submission' do
    before do
      sign_in('unauthorized_student')
    end

    it 'does not allow the student to edit the submission' do
      visit edit_submission_path(submission.dissertation_id)

      expect(page).to have_content('You are unauthorized to see this')
    end
  end

  describe 'when the authorized student is authenticated' do
    before do
      sign_in(submission.sunetid)
    end

    it 'allows the user to edit a submission' do
      visit edit_submission_path(submission.dissertation_id)

      expect(page).to have_content("Welcome, #{submission.first_name}")

      collapse_items = page.all('.collapse-item')
      expect(collapse_items.length).to eq(7)

      # Step 7
      within(collapse_items[6]) do
        expect(page).to have_css('.alert-danger',
                                 text: 'You must complete sections 1-6')
        expect(page).to have_button('Review and submit', disabled: true)
      end

      expect(page).to have_css('.progress-card li', count: 7)
      within('.progress-card #step-1') do
        expect(page).to have_text('Citation details verified')
        expect(page).to have_css('.character-circle-disabled', text: '1')
        expect(page).to have_no_css('.character-circle-success')
      end

      # Step 1
      within(collapse_items[0]) do
        expect(page).to have_css('.collapse-header h2', text: 'Verify your citation details')
        expect(page).to have_css('.character-circle-disabled', text: '1')
        expect(page).to have_css('.badge-in-progress', text: 'In Progress')
        expect(page).to have_no_css('.badge-completed')
        expect(page).to have_no_button('Undo your confirmation')
        expect(page).to have_content('By clicking Confirm, I verify ')
        click_button 'Confirm'
        # Body is collapsed.
        expect(page).to have_no_button('Confirm')
        expect(page).to have_css('.character-circle-success', text: '1')
        expect(page).to have_no_css('.badge-in-progress')
        expect(page).to have_css('.badge-completed', text: 'Completed')
        # Expand the body
        click_button 'Undo your confirmation'
        # Collapse body
        click_button 'Confirm'
      end

      within('.progress-card #step-1') do
        expect(page).to have_text('Citation details verified')
        expect(page).to have_no_css('.character-circle-disabled')
        expect(page).to have_css('.character-circle-success')
      end

      # Step 2
      within(collapse_items[1]) do
        expect(page).to have_button('Done', disabled: true)
        fill_in 'Abstract', with: 'This is a sample abstract for testing.'
        click_button 'Done'
      end

      # Step 3
      within(collapse_items[2]) do
        click_button 'Confirm'
      end

      # Step 4 and 5 are not implemented yet.

      # Step 6
      within(collapse_items[5]) do
        expect(page).to have_button('Done', disabled: true)

        click_link_or_button 'View the Stanford University publication license'
        within('.modal#stanford-license-confirm') do
          expect(page).to have_content('Stanford University Thesis & Dissertation Publication License')
          click_button 'Close'
        end

        click_link_or_button 'View the Creative Commons licenses'
        within('.modal#cc-licenses') do
          expect(page).to have_content('Creative Commons Licenses')
          click_button 'Close'
        end

        check 'I have read and agree to the terms of the Stanford University license'
        select 'CC Attribution license', from: 'submission_cclicense'
        select '6 months', from: 'submission_embargo'
        click_button 'Done'
      end

      # Step 7
      within(collapse_items[6]) do
        expect(page).to have_css('.alert-info',
                                 text: 'You have completed sections 1-6.')
        click_button('Review and submit')
      end

      within('.modal#review-modal') do
        expect(page).to have_content('Review and submit')

        # Step 1
        expect(page).to have_css('h2', text: 'Citation details')

        click_link_or_button 'Submit to Registrar'
      end

      expect(page).to have_current_path(submission_path(submission.dissertation_id))
      expect(page).to have_content('Not implemented yet')

      expect(submission.reload.citation_verified).to eq('true')
      expect(submission.abstract).to eq('This is a sample abstract for testing.')
      expect(submission.format_reviewed).to eq('true')
      expect(submission.sulicense).to eq('true')
      expect(submission.cclicense).to eq('1') # CC Attribution license
      expect(submission.cclicensetype).to eq('CC Attribution license')
      expect(submission.embargo).to eq('6 months')
    end
  end
end
