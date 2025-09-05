# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::SubmittedStepComponent, type: :component do
  let(:submission) { create(:submission, name: 'Doe, Jane') }

  context 'when all steps are not done' do
    before do
      allow(SubmissionPresenter).to receive(:all_done?).and_return(false)
    end

    it 'renders the component' do
      render_inline(described_class.new(submission:))
      expect(page).to have_css('h2', text: 'Review and submit to Registrar')

      expect(page).to have_css('.alert-danger', text: "You must complete sections 1-#{TOTAL_STEPS - 1}")
      expect(page).to have_css('span', text: 'Review and submit', class: 'disabled')
    end
  end

  context 'when all steps are done' do
    before do
      allow(SubmissionPresenter).to receive(:all_done?).and_return(true)
    end

    it 'renders the component' do
      render_inline(described_class.new(submission:))
      expect(page).to have_css('h2', text: 'Review and submit to Registrar')

      expect(page).to have_css('.alert-info', text: "You have completed sections 1-#{TOTAL_STEPS - 1}")
      expect(page).to have_link('Review and submit')
    end
  end
end
