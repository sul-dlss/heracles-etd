# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::ProgressCardComponent, type: :component do
  let(:submission_presenter) do
    instance_double(SubmissionPresenter)
  end

  before do
    allow(submission_presenter).to receive(:step_done?).with(1).and_return(true)
    allow(submission_presenter).to receive(:step_done?).with(2).and_return(true)
    allow(submission_presenter).to receive(:step_done?).with(3).and_return(true)
    allow(submission_presenter).to receive(:step_done?).with(4).and_return(true)
    allow(submission_presenter).to receive(:step_done?).with(5).and_return(false)
    allow(submission_presenter).to receive(:step_done?).with(6).and_return(false)
    allow(submission_presenter).to receive(:step_done?).with(7).and_return(false)
  end

  it 'renders the list of steps' do
    render_inline(described_class.new(submission_presenter:))
    expect(page).to have_css('h2', text: 'Progress')
    expect(page).to have_css('li', count: 7)
    expect(page).to have_css('.character-circle-disabled', count: 3)
    expect(page).to have_css('.character-circle-success', count: 4)
    expect(page).to have_css('.character-circle-blank', count: 2)
  end
end
