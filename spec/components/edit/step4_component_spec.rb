# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Edit::Step4Component, type: :component do
  let(:submission) { create(:submission) }
  let(:submission_presenter) { SubmissionPresenter.new(submission:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, submission, vc_test_controller.view_context, {}) }

  it 'renders the component' do
    render_inline(described_class.new(form:, submission_presenter:))
    expect(page).to have_css('h2', text: 'Upload your dissertation')
    expect(page).to have_button('Upload PDF')
  end
end
