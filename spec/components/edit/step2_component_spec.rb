# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::Step2Component, type: :component do
  let(:submission) { create(:submission) }
  let(:submission_presenter) { SubmissionPresenter.new(submission:) }

  it 'renders the component' do
    render_inline(described_class.new(submission_presenter:))
    expect(page).to have_css('h2', text: 'Enter your abstract')
    expect(page).to have_css('textarea[name="submission[abstract]"]')
  end
end
