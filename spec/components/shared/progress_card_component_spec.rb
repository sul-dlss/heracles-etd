# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::ProgressCardComponent, type: :component do
  let(:submission_presenter) do
    double(SubmissionPresenter, submitted_at: DateTime.parse('2023-01-01 12:00:00')) # rubocop:disable Rspec/VerifiedDoubles
  end

  before do
    allow(submission_presenter).to receive(:step_done?).with(1).and_return(true)
    allow(submission_presenter).to receive(:step_done?).with(2).and_return(true)
    allow(submission_presenter).to receive(:step_done?).with(3).and_return(true)
    allow(submission_presenter).to receive(:step_done?).with(4).and_return(true)
    allow(submission_presenter).to receive(:step_done?).with(5).and_return(false)
    allow(submission_presenter).to receive(:step_done?).with(6).and_return(false)
    allow(submission_presenter).to receive(:step_done?).with(7).and_return(true)
    allow(submission_presenter).to receive(:step7_done?).and_return(true)
  end

  it 'renders the list of steps' do
    render_inline(described_class.new(submission_presenter:))
    expect(page).to have_css('h2', text: 'Progress')
    expect(page).to have_css('li', count: 7)
    expect(page).to have_css('.character-circle-disabled', count: 2)
    expect(page).to have_css('.character-circle-success', count: 5)
    expect(page).to have_css('.character-circle-blank', count: 2)
    expect(page).to have_css('#step-7 .text-muted', text: 'January  1, 2023 12:00pm')
  end
end
