# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::CollapseItemComponent, type: :component do
  let(:submission) { create(:submission) }

  it 'renders the collapse item' do
    render_inline(described_class.new(step_number: 2, title: 'Step 2'))

    header = page.find('.collapse-item .collapse-header')
    expect(header).to have_css('.character-circle-disabled', text: '2')
    expect(header).to have_css('h2', text: 'Step 2')
    expect(header).to have_css('button .show-when-expanded', text: 'Editing')
    expect(header).to have_css('button .show-when-collapsed', text: 'Edit this section')

    body = page.find('.collapse-item .collapse-body')
    expect(body).to have_content('Click Done to complete this section.')
    expect(body).to have_button('Done')
  end

  context 'when a review variant' do
    it 'renders the review labels' do
      render_inline(described_class.new(step_number: 3, title: 'Step 3', edit_variant: :review))

      header = page.find('.collapse-item .collapse-header')
      expect(header).to have_css('button .show-when-expanded', text: 'Reviewing')
      expect(header).to have_css('button .show-when-collapsed', text: 'Undo your confirmation')
    end
  end

  context 'when done text and label are provided' do
    it 'uses the provided text and label' do
      render_inline(described_class.new(step_number: 4, title: 'Step 4', done_text: 'Finish this section',
                                        done_label: 'Finish'))

      body = page.find('.collapse-item .collapse-body')
      expect(body).to have_content('Finish this section')
      expect(body).to have_button('Finish')
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
