# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::Step7Component, type: :component do
  let(:submission) { create(:submission, name: 'Doe, Jane') }
  let(:submission_presenter) { instance_double(SubmissionPresenter) }

  context 'when all steps are not done' do
    before do
      allow(submission_presenter).to receive(:all_done?).and_return(false)
    end

    it 'renders the component' do
      render_inline(described_class.new(submission_presenter:))
      expect(page).to have_css('h2', text: 'Review and submit to Registrar')

      expect(page).to have_css('.alert-danger', text: 'You must complete sections 1-6')
      expect(page).to have_button('Review and submit', disabled: true)
    end
  end

  context 'when all steps are done' do
    before do
      allow(submission_presenter).to receive(:all_done?).and_return(true)
    end

    it 'renders the component' do
      render_inline(described_class.new(submission_presenter:))
      expect(page).to have_css('h2', text: 'Review and submit to Registrar')

      expect(page).to have_css('.alert-info', text: 'You have completed sections 1-6')
      expect(page).to have_button('Review and submit', disabled: false)
    end
  end
end
