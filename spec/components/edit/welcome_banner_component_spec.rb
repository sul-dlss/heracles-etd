# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::WelcomeBannerComponent, type: :component do
  let(:submission) { create(:submission) }
  let(:user) { User.new(sunetid: submission.sunetid) }

  it 'renders the welcome banner' do
    render_inline(described_class.new(submission: submission))
    expect(page).to have_css('.alert.alert-note')
    expect(page).to have_css('h2', text: 'Welcome, Jane')
    expect(page).to have_text('Ph.D. student')
    expect(page).to have_css('.banner-header', text: 'Bookmark this page.')
  end
end
