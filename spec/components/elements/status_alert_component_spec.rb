# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::StatusAlertComponent, type: :component do
  it 'renders the status alert without a role' do
    render_inline(described_class.new(title: 'Test Alert', variant: :warning))

    expect(page).to have_css('.alert.alert-warning:not([role="alert"])')
  end
end
