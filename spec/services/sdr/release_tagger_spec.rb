# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sdr::ReleaseTagger do
  let(:etd) { create(:submission) }

  describe '.tag' do
    let(:fake_instance) { instance_double(described_class, tag: true) }

    before do
      allow(described_class).to receive(:new).with(druid: etd.druid).and_return(fake_instance)
    end

    it 'calls #tag on a newly created tagger instance' do
      described_class.tag(druid: etd.druid)
      expect(fake_instance).to have_received(:tag).once
    end
  end

  describe '#tag' do
    let(:tagger) { described_class.new(druid: etd.druid) }
    let(:release_tags) { instance_double(Dor::Services::Client::ReleaseTags, create: true) }
    let(:object_client) { instance_double(Dor::Services::Client::Object, release_tags:) }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    it 'creates releases tags via dor-services API call' do
      call_count = 0
      allow(release_tags).to receive(:create) do |params|
        call_count += 1
        if call_count.odd?
          expect(params[:tag].to).to eq 'Searchworks'
        else
          expect(params[:tag].to).to eq 'PURL sitemap'
        end
      end
      tagger.tag
    end
  end
end
