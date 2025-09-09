# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shared::SupplementalFilesStepBodyHelpComponent, type: :component do
  it 'renders the help content for the supplemental files step' do
    render_inline(described_class.new)

    expect(page).to have_content('Does your dissertation include supplemental files?')
    expect(page).to have_content('Click Yes if your dissertation contains supplemental files.')
  end
end
