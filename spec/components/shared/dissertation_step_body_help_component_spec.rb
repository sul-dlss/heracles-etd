# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::DissertationStepBodyHelpComponent, type: :component do
  it 'renders the help content for the dissertation step' do
    render_inline(described_class.new)

    expect(page).to have_content('Your dissertation must be a single PDF file.')
    expect(page).to have_link("Review the Registrar's official submission guidelines")
  end
end
