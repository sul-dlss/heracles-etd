# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::Step8Component, type: :component do
  let(:submission) { create(:submission, :submitted) }
  let(:cclicense) { '1' }

  it 'renders the component' do
    render_inline(described_class.new(submission:))

    expect(page).to have_css('h2', text: 'Review and submit to Registrar')
    expect(page).to have_css('.alert-info', text: 'Dissertation submitted to Registrar')
    expect(page).to have_css('time[datetime="2023-01-01T00:00:00Z"]')
  end
end
