# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::PermissionFilesStepBodyHelpComponent, type: :component do
  it 'renders the help content for the permission files step' do
    render_inline(described_class.new)

    expect(page).to have_content('Does your dissertation include copyrighted material?')
    expect(page).to have_content('Click Yes if your dissertation contains copyrighted material.')
  end
end
