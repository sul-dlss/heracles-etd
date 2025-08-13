# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::StepComponent, type: :component do
  let(:submission) { create(:submission) }

  it 'renders the step' do
    render_inline(described_class.new(step_number: 2, title: 'Step 2'))

    header = page.find('.collapse-item .collapse-header')
    expect(header).to have_css('.character-circle-disabled', text: '2')
    expect(header).to have_css('h2', text: 'Step 2')
    expect(header).to have_css('.badge-in-progress:not(.d-none)', text: 'In Progress')
    expect(header).to have_css('.badge-completed.d-none', text: 'Completed')
    expect(header).to have_button('Edit this section', class: 'd-none')

    expect(page).to have_css('.collapse-item .collapse.show')

    body = page.find('.collapse-item .collapse-body')
    expect(body).to have_content('Click Done to complete this section.')
    expect(body).to have_css('button[data-action="submit-form#toggleAndSubmit"][data-bs-target="#collapse_2"]',
                             text: 'Done')
  end

  context 'when not showing the step' do
    it 'renders the step item with collapsed state' do
      render_inline(described_class.new(step_number: 2, title: 'Step 2', show: false))

      header = page.find('.collapse-item .collapse-header')
      expect(header).to have_css('.character-circle-success', text: '2')
      expect(header).to have_css('.badge-in-progress.d-none', text: 'In Progress')
      expect(header).to have_css('.badge-completed:not(.d-none)', text: 'Completed')
      expect(header).to have_css('button:not(.d-none)', text: 'Edit this section')

      expect(page).to have_css('.collapse-item .collapse:not(.show)')
    end
  end

  context 'when done params are provided' do
    it 'uses the provided text and label' do
      render_inline(described_class.new(step_number: 4, title: 'Step 4', done_text: 'Finish this section',
                                        done_label: 'Finish', done_data: { action: 'my-action#finish' },
                                        done_disabled: true))

      body = page.find('.collapse-item .collapse-body')
      expect(body).to have_content('Finish this section')
      expect(body).to have_css('button[data-action="my-action#finish submit-form#toggleAndSubmit"][disabled]',
                               text: 'Finish')
    end
  end

  context 'when edit params are provided' do
    it 'uses the provided edit label and data' do
      render_inline(described_class.new(step_number: 3, title: 'Step 3',
                                        edit_label: 'Modify this section',
                                        edit_data: { action: 'edit-form#modify' }))

      header = page.find('.collapse-item .collapse-header')
      expect(header).to have_css('button.d-none[data-action="edit-form#modify"][data-bs-target="#collapse_3"]',
                                 text: 'Modify this section')
    end
  end

  context 'with help content' do
    it 'renders the help content' do
      render_inline(described_class.new(step_number: 5, title: 'Step 5')) do |component|
        component.with_help_content { '<p>Helpful information here.</p>'.html_safe }
      end

      expect(page).to have_css('.collapse-item .collapse-header .collapse-header-help p',
                               text: 'Helpful information here.')
    end
  end

  context 'with body content' do
    it 'renders the body content' do
      render_inline(described_class.new(step_number: 6, title: 'Step 6')) do |component|
        component.with_body_content { '<p>Body content goes here.</p>'.html_safe }
      end

      expect(page).to have_css('.collapse-item .collapse-body p', text: 'Body content goes here.')
    end
  end

  context 'with footer content' do
    it 'renders the footer content' do
      render_inline(described_class.new(step_number: 7, title: 'Step 7')) do |component|
        component.with_footer_content { '<p>Footer content goes here.</p>'.html_safe }
      end

      body = page.find('.collapse-item .collapse-body')
      expect(body).to have_css('p', text: 'Footer content goes here.')
      expect(body).to have_no_content('Click Done to complete this section.')
      expect(body).to have_no_button('Done')
    end
  end
end
