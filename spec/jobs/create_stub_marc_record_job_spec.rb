# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateStubMarcRecordJob do
  subject(:job) { described_class.new }

  let(:druid) { 'druid:mj151qw9093' }

  before do
    allow(Honeybadger).to receive(:context)
    allow(Marc::StubRecordPipeline).to receive(:run!)
  end

  describe '#perform' do
    before do
      job.perform(druid)
    end

    it 'adds the druid to Honeybadger context' do
      expect(Honeybadger).to have_received(:context).with(druid:).once
    end

    it 'runs the stub MARC record pipeline' do
      expect(Marc::StubRecordPipeline).to have_received(:run!).with(druid:).once
    end
  end
end
