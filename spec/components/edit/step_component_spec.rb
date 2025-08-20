# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::StepComponent, type: :component do
  let(:submission) { create(:submission) }

  it 'renders the step' do
    render_inline(described_class.new(step: SubmissionPresenter::CITATION_STEP, title: 'Step 1',
                                      submission:))

    expect(page)
      .to have_css('section.card-step[aria-label="1 Step 1 in progress"]')
    header = page.find('.card-step .card-step-header')
    expect(header).to have_css('.character-circle-disabled', text: '1')
    expect(header).to have_css('h2', text: 'Step 1')
    expect(header).to have_css('.badge-in-progress', text: 'In Progress')
    expect(header).to have_no_css('.badge-completed')
    expect(header).to have_no_button('Edit this section')

    body = page.find('.card-step .card-step-body')
    expect(body).to have_content('Click Done to complete this section.')
    expect(body).to have_field('submission[citation_verified]', type: 'hidden', with: 'true')
    expect(body).to have_button('Done', type: 'submit')
  end

  context 'when not showing the step' do
    let(:submission) { create(:submission, citation_verified: 'true') }

    it 'renders the step item without the body' do
      render_inline(described_class.new(step: SubmissionPresenter::CITATION_STEP, title: 'Step 1',
                                        submission:))

      expect(page)
        .to have_css('section.card-step[aria-label="1 Step 1 completed"]')
      header = page.find('.card-step .card-step-header')
      expect(header).to have_css('.character-circle-success', text: '1')
      expect(header).to have_no_css('.badge-in-progress')
      expect(header).to have_css('.badge-completed', text: 'Completed')
      expect(header).to have_field('submission[citation_verified]', type: 'hidden', with: 'false')
      expect(header).to have_button('Edit this section', type: 'submit')

      expect(page).to have_no_css('.card-step .card-step-body')
    end
  end

  context 'when done params are provided' do
    it 'uses the provided text and label' do
      render_inline(described_class.new(step: SubmissionPresenter::FORMAT_STEP, title: 'Step 4', submission:,
                                        done_text: 'Finish this section',
                                        done_label: 'Finish', done_data: { action: 'my-action#finish' },
                                        done_disabled: true))

      body = page.find('.card-step .card-step-body')
      expect(body).to have_content('Finish this section')
      expect(body).to have_css('button[data-action="my-action#finish"][disabled]',
                               text: 'Finish')
    end
  end

  context 'when edit params are provided' do
    let(:submission) { create(:submission, format_reviewed: 'true') }

    it 'uses the provided edit label and data' do
      render_inline(described_class.new(step: SubmissionPresenter::FORMAT_STEP, title: 'Step 4', submission:,
                                        edit_label: 'Modify this section'))

      header = page.find('.card-step .card-step-header')
      expect(header).to have_button('Modify this section')
    end
  end

  context 'with help content' do
    it 'renders the help content' do
      render_inline(described_class.new(step: SubmissionPresenter::CITATION_STEP, title: 'Step 5',
                                        submission:)) do |component|
        component.with_help_content { '<p>Helpful information here.</p>'.html_safe }
      end

      expect(page).to have_css('.card-step .card-step-header .header-help p',
                               text: 'Helpful information here.')
    end
  end

  context 'with body content' do
    it 'renders the body content' do
      render_inline(described_class.new(step: SubmissionPresenter::FORMAT_STEP, title: 'Step 6',
                                        submission:)) do |component|
        component.with_body_content { '<p>Body content goes here.</p>'.html_safe }
      end

      expect(page).to have_css('.card-step .card-step-body p', text: 'Body content goes here.')
    end
  end

  context 'with footer content' do
    it 'renders the footer content' do
      render_inline(described_class.new(step: SubmissionPresenter::SUBMITTED_STEP, title: 'Step 7',
                                        submission:)) do |component|
        component.with_footer_content { '<p>Footer content goes here.</p>'.html_safe }
      end

      body = page.find('.card-step .card-step-body')
      expect(body).to have_css('p', text: 'Footer content goes here.')
      expect(body).to have_no_content('Click Done to complete this section.')
      expect(body).to have_no_button('Done')
    end
  end
end
