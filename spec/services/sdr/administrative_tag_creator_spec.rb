# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sdr::AdministrativeTagCreator do
  let(:etd) { Submission.new(druid:, etd_type: 'Dissertation') }
  let(:druid) { 'druid:ab123cd4567' }
  let(:obj_client) { instance_double(Dor::Services::Client::Object, administrative_tags: tags_client) }
  let(:tags_client) { instance_double(Dor::Services::Client::AdministrativeTags, create: true) }

  before do
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(obj_client)
  end

  describe '.create' do
    let(:fake_creator) { instance_double(described_class, create: true) }

    before do
      allow(described_class).to receive(:new).and_return(fake_creator)
    end

    it 'calls #create on a new instance' do
      described_class.create(etd)
      expect(fake_creator).to have_received(:create).once
    end
  end

  describe '#create' do
    subject(:creator) { described_class.new(etd) }

    it 'uses dor-services-client to create a new tag' do
      creator.create
      expect(tags_client).to have_received(:create).with(tags: ['ETD : Dissertation']).once
    end
  end
end
