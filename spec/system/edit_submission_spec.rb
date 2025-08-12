# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit Submission' do
  let(:submission) { create(:submission) }

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
      expect(page).to have_button('Reviewing', disabled: true)
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

    # Step 4
    within(collapse_items[3]) do
      click_button 'Done'
    end

    # Step 5
    within(collapse_items[4]) do
      click_button 'Done'
    end

    # Step 6
    within(collapse_items[5]) do
      click_button 'Done'
    end

    # Step 7
    within(collapse_items[6]) do
      expect(page).to have_css('.alert-info',
                               text: 'You have completed sections 1-6.')
      click_button('Review and submit')
    end

    expect(page).to have_current_path(submission_path(submission.dissertation_id))
    expect(page).to have_content('Not implemented yet')
    expect(submission.reload.abstract).to eq('This is a sample abstract for testing.')
  end
end
