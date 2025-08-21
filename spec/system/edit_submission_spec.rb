# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Edit Submission' do
  let(:submission) { create(:submission) }

  before do
    allow(SubmitToRegistrarService).to receive(:call) do |args|
      args[:submission].update!(submitted_at: Time.current)
    end

    sign_in(submission.sunetid)
  end

  it 'allows the user to edit a submission' do
    visit edit_submission_path(submission.dissertation_id)

    expect(page).to have_css('header', text: 'Review and submit your dissertation')
    expect(page).to have_content("Welcome, #{submission.first_name}")

    cards = page.all('.card-step')
    expect(cards.length).to eq(TOTAL_STEPS)

    # Step 7
    within(cards.last) do
      expect(page).to have_css('.alert-danger',
                               text: "You must complete sections 1-#{TOTAL_STEPS - 1}")
      expect(page).to have_button('Review and submit', disabled: true)
    end

    expect(page).to have_css('.progress-card li', count: TOTAL_STEPS)
    within('.progress-card li:first-of-type') do
      expect(page).to have_text('Citation details verified')
      expect(page).to have_css('.character-circle-disabled', text: '1')
      expect(page).to have_no_css('.character-circle-success')
    end

    # Citation step
    within(cards[0]) do
      expect(page).to have_css('.card-step-header h2', text: 'Verify your citation details')
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
      expect(page.active_element).to eq find_button('Undo your confirmation')

      # Expand the body
      click_button 'Undo your confirmation'
      btn = find_button('Confirm')
      expect(page.active_element).to eq btn

      # Collapse body
      click_button 'Confirm'
    end

    within('.progress-card li:first-of-type') do
      expect(page).to have_text('Citation details verified')
      expect(page).to have_no_css('.character-circle-disabled')
      expect(page).to have_css('.character-circle-success')
    end

    # Abstract step
    within(cards[1]) do
      expect(page).to have_button('Done', disabled: true)
      fill_in 'Abstract', with: 'This is a sample abstract for testing.'
      click_button 'Done'
      btn = find_button('Edit this section')
      expect(page.active_element).to eq btn

      # Expand body
      click_button 'Edit this section'
      field = find_field('Abstract')
      expect(page.active_element).to eq field

      # Collapse body
      click_button 'Done'
    end

    # Format step
    within(cards[2]) do
      click_button 'Confirm'
    end

    # Dissertation file step
    within(cards[3]) do
      expect(page).to have_button('Done', disabled: true)
      attach_file 'Upload PDF', Rails.root.join('spec/fixtures/files/dissertation.pdf')

      within('#dissertation-file-table') do
        expect(page).to have_css('td', text: 'dissertation.pdf')
        click_link_or_button 'Remove'
      end

      attach_file 'Upload PDF', Rails.root.join('spec/fixtures/files/dissertation.pdf')

      click_button 'Done'

      btn = find_button('Edit this section')
      expect(page.active_element).to eq btn

      click_button 'Edit this section'
      btn = find_button('Done')
      expect(page.active_element).to eq btn

      click_button 'Remove'
      field = find_field('Upload PDF')
      expect(page.active_element).to eq field

      attach_file 'Upload PDF', Rails.root.join('spec/fixtures/files/dissertation.pdf')

      click_button 'Done'
    end

    # Supplemental files step
    within(cards[4]) do
      expect(page).to have_button('Done', disabled: false)
      attach_file 'Upload supplemental files', Rails.root.join('spec/fixtures/files/supplemental_1.pdf')

      within('#supplemental-files-table') do
        expect(page).to have_css('td', text: 'supplemental_1.pdf')
        click_link_or_button 'Remove'
      end

      attach_file 'Upload supplemental files', [
        Rails.root.join('spec/fixtures/files/supplemental_1.pdf'),
        Rails.root.join('spec/fixtures/files/supplemental_2.pdf')
      ]

      click_button 'Done'

      btn = find_button('Edit this section')
      expect(page.active_element).to eq btn

      click_button 'Edit this section'
      field = find_field('Upload supplemental files')
      expect(page.active_element).to eq field

      click_button 'Done'
    end

    # Rights step
    within(cards[5]) do
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

      btn = find_button('Edit this section')
      expect(page.active_element).to eq btn

      click_button 'Edit this section'
      field = find_field('I have read and agree to the terms of the Stanford University license')
      expect(page.active_element).to eq field

      click_button 'Done'
    end

    # Submitted step
    within(cards[6]) do
      expect(page).to have_css('.alert-info',
                               text: "You have completed sections 1-#{TOTAL_STEPS - 1}.")
      click_button('Review and submit')
    end

    expect(page).to have_current_path(review_submission_path(submission.dissertation_id))
    expect(page).to have_content('Review and submit')
    expect(page).to have_css('h2', text: 'Citation details')
    expect(page).to have_css('h2', text: 'Abstract')
    expect(page).to have_css('p', text: 'This is a sample abstract for testing.')
    expect(page).to have_css('h2', text: 'Review your dissertation\'s formatting')
    expect(page).to have_css('h2', text: 'Apply copyright and license terms')
    expect(page).to have_text('This work is licensed under a CC Attribution license.')
    expect(page).to have_css('h2', text: 'Upload your dissertation')
    expect(page).to have_link('dissertation.pdf')
    expect(page).to have_no_button('Remove')

    click_link_or_button 'Submit to Registrar'

    expect(page).to have_current_path(submission_path(submission.dissertation_id))
    expect(page).to have_content("Welcome, #{submission.first_name}")

    expect(submission.reload.citation_verified).to eq('true')
    expect(submission.abstract).to eq('This is a sample abstract for testing.')
    expect(submission.format_reviewed).to eq('true')
    expect(submission.sulicense).to eq('true')
    expect(submission.cclicense).to eq('1') # CC Attribution license
    expect(submission.cclicensetype).to eq('CC Attribution license')
    expect(submission.embargo).to eq('6 months')
    expect(submission.dissertation_file.attached?).to be true

    expect(SubmitToRegistrarService).to have_received(:call).with(submission: submission)
  end
end
