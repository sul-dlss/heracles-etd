# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::StepComponent, type: :component do
  let(:submission) { create(:submission, :submitted) }

  it 'renders the component' do
    render_inline(described_class.new(step: SubmissionPresenter::CITATION_STEP, title: 'Citation details', submission:))

    expect(page).to have_css('section.card[aria-labelledby="step-1-character-circle step-1-title step-1-badge"]')
    header = page.find('.card .card-header')
    expect(header).to have_css('.character-circle-success', text: '1')
    expect(header).to have_css('h2', text: 'Citation details')
    expect(header).to have_css('.badge-completed')
  end

  context 'without a step number' do
    it 'does not render the character circle or completed badge' do
      render_inline(described_class.new(title: 'Citation details'))

      expect(page).to have_css('section.card[aria-labelledby="step-none-title"]')
      header = page.find('.card .card-header')
      expect(header).to have_no_css('.character-circle-success')
      expect(header).to have_no_css('.badge-completed')
    end
  end

  context 'with help content' do
    it 'renders the help content' do
      render_inline(described_class.new(step: SubmissionPresenter::CITATION_STEP,
                                        title: 'Citation details',
                                        submission:)) do |component|
        component.with_help_content { '<p>Helpful information here.</p>'.html_safe }
      end

      expect(page).to have_css('.card .card-header .header-help p',
                               text: 'Helpful information here.')
    end
  end

  context 'with body content' do
    it 'renders the body content' do
      render_inline(described_class.new(step: SubmissionPresenter::CITATION_STEP,
                                        title: 'Citation details',
                                        submission:)) do |component|
        component.with_body_content { '<p>Body content goes here.</p>'.html_safe }
      end

      expect(page).to have_css('.card .card-body p', text: 'Body content goes here.')
    end
  end
end
