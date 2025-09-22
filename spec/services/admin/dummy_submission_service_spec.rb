# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DummySubmissionService do
  let(:dummy_cocina) { instance_double(Cocina::Models::DRO, externalIdentifier: 'druid:vm000jb0557') }
  let(:submission) { described_class.call(sunetid: 'testuser') }

  before do
    allow(RegisterService).to receive(:register).and_return(dummy_cocina)
  end

  it 'creates a dummy submission with a registered druid' do
    expect(submission).to be_a(Submission)
    expect(submission.sunetid).to eq('testuser')

    expect(submission.readers.count).to eq(1)
    reader = submission.readers.first
    expect(reader.sunetid).to eq('testuser')

    expect(RegisterService).to have_received(:register).once
  end
end
