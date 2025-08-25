# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::ButtonFormComponent, type: :component do
  let(:submission) { create(:submission) }

  it 'renders the component with a button' do
    render_inline(described_class.new(submission:, field: :citation_verified, value: 'true', label: 'Done'))

    expect(page).to have_css("form[action=\"/submit/#{submission.dissertation_id}\"]")
    expect(page).to have_field('submission[citation_verified]', type: 'hidden', with: 'true')
    expect(page).to have_button('Done', type: 'submit')
  end

  context 'with content' do
    it 'renders the component with a button' do
      render_inline(described_class.new(submission:, field: :citation_verified,
                                        value: 'true').with_content('My button'))

      expect(page).to have_button('My button', type: 'submit')
    end
  end
end
