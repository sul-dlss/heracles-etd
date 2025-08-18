# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::BannerComponent, type: :component do
  it 'renders the banner' do
    render_inline(described_class.new)
    expect(page).to have_css(".alert.alert-note.banner[role='banner']")
    expect(page).to have_no_css('.banner-header')
    expect(page).to have_no_css('.banner-body')
    expect(page).to have_css('div.bi.bi-exclamation-circle-fill')
  end

  context 'with a class' do
    it 'renders the class' do
      render_inline(described_class.new(classes: ['custom-class']))
      expect(page).to have_css('.alert.custom-class')
    end
  end

  context 'with a title' do
    it 'renders the title' do
      render_inline(described_class.new(title: 'My title'))
      expect(page).to have_css('.banner-header', text: 'My title')
    end
  end

  context 'with a role' do
    it 'renders the role' do
      render_inline(described_class.new(role: 'region'))
      expect(page).to have_css('.banner[role="region"]')
    end
  end

  context 'with an aria-label' do
    it 'renders the aria-label' do
      render_inline(described_class.new(aria_label: 'My aria label'))
      expect(page).to have_css('.banner[aria-label="My aria label"]')
    end
  end

  context 'with a header' do
    it 'renders the header' do
      render_inline(described_class.new.tap do |component|
        component.with_header { '<h1>My header</h1>'.html_safe }
      end)
      expect(page).to have_css('h1', text: 'My header')
    end
  end

  context 'with a body' do
    it 'renders the body' do
      render_inline(described_class.new.tap do |component|
        component.with_body { '<p>My body</p>'.html_safe }
      end)
      expect(page).to have_css('.banner-body p', text: 'My body')
    end
  end

  context 'with a variant' do
    it 'renders the correct icon and classes for variant' do
      render_inline(described_class.new(variant: :success))
      expect(page).to have_css(".alert.alert-success.banner[role='banner']")
      expect(page).to have_css('div.bi.bi-check-circle-fill')
    end
  end

  context 'with an invalid variant' do
    it 'raises an error' do
      expect do
        render_inline(described_class.new(variant: :invalid))
      end.to raise_error(ArgumentError)
    end
  end
end
