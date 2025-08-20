# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DummySubmissionService do
  let(:submission) { described_class.call(sunetid: 'testuser') }

  it 'creates a dummy submission' do
    expect(submission).to be_a(Submission)
    expect(submission.sunetid).to eq('testuser')

    expect(submission.readers.count).to eq(1)
    reader = submission.readers.first
    expect(reader.sunetid).to eq('testuser')
  end
end
