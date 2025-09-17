# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::WelcomeBannerComponent, type: :component do
  context 'with a submitted submission' do
    let(:submission) { create(:submission, :submitted) }

    it 'renders the welcome banner' do
      render_inline(described_class.new(submission: submission))
      expect(page).to have_css('.alert.alert-success[role="region"][aria-label="Welcome"]')
      expect(page).to have_css('h2', text: 'Welcome, Jane')
      expect(page).to have_text('Ph.D. student')
      expect(page).to have_css('.banner-header', text: 'Submission successful.')
      expect(page).to have_link(submission.purl)
      expect(page).to have_text(submission.doi)
      expect(page).to have_link('Download your submitted file')
    end
  end

  context 'with an approved submission' do
    let(:submission) { create(:submission, :submitted, :ready_for_cataloging) }

    it 'renders the welcome banner' do
      render_inline(described_class.new(submission: submission))
      expect(page).to have_css('.alert.alert-success[role="region"][aria-label="Welcome"]')
      expect(page).to have_css('h2', text: 'Welcome, Jane')
      expect(page).to have_text('Ph.D. student')
      expect(page).to have_css('.banner-header', text: 'Submission approved.')
      expect(page).to have_link(submission.purl)
      expect(page).to have_text(submission.doi)
      expect(page).to have_link('Download your submitted file')
    end
  end
end
