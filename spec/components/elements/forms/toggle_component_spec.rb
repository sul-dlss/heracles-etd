# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::Forms::ToggleComponent, type: :component do
  let(:submission) { create(:submission, name: 'Doe, Jane') }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }
  let(:field_name) { 'supplemental_files_uploaded' }
  let(:container_classes) { 'mb-4' }
  let(:component) { described_class.new(form:, field_name:, container_classes:) }

  before do
    component.with_left_toggle_option(form:, field_name:, label: 'Yes', value: true, data: { test: 'test_data' })
    component.with_right_toggle_option(form:, field_name:, label: 'No', value: false, data: { test: 'more_test_data' })
  end

  it 'creates toggle field with label' do
    render_inline(component)
    expect(page).to have_css('label.form-label', text: 'Supplemental files uploaded', visible: :all)
    expect(page).to have_css('input[data-test="test_data"]')
    expect(page).to have_css('label.btn.rounded-start-pill', text: 'Yes')
    expect(page).to have_css('label.btn.rounded-end-pill', text: 'No')
    expect(page).to have_no_css('p.form-text')
  end
end
