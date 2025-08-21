# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PsRegistrarService do
  let(:submission) { build(:submission, :submitted) }

  describe '.call' do
    let(:instance) { instance_double(described_class, call: nil) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    it 'invokes #call on a new instance' do
      described_class.call(submission:)
      expect(instance).to have_received(:call).once
    end
  end

  describe '#call' do
    let(:fake_response) do
      instance_double(OAuth2::Response, status:, parsed: response_hash)
    end
    let(:response_hash) do
      {
        response: { status: 'SUCCESS', message: 'Updated the Dissertation data' }
      }
    end
    let(:peoplesoft_base_url) { 'https://example.stanford.edu/peoplesoft' }
    let(:service) { described_class.new(submission:) }
    let(:status) { 200 }

    before do
      allow(Honeybadger).to receive(:notify)
      allow(Rails.logger).to receive(:info)
      allow(service).to receive(:response).and_return(fake_response)
      allow(Settings.peoplesoft).to receive(:base_url).and_return(peoplesoft_base_url)
    end

    it 'logs a message to indicate an update is being sent to PeopleSoft' do
      service.call
      expect(Rails.logger).to have_received(:info).with(/Submitting ETD update to PeopleSoft/).once
    end

    it 'returns true' do
      expect(service.call).to be true
    end

    context 'when PeopleSoft URL is blank' do
      let(:peoplesoft_base_url) { '' }

      it 'returns false' do
        expect(service.call).to be false
      end
    end

    context 'when post returns a non-200 response' do
      let(:status) { 500 }

      it 'returns false' do
        expect(service.call).to be false
      end

      it 'notifies Honeybadger with the expected context' do
        service.call
        expect(Honeybadger).to have_received(:notify).with('Failed to submit PS XML for dissertation', context: {
                                                             response: response_hash
                                                           })
      end
    end

    context 'when an exception is raised' do
      before do
        allow(service).to receive(:response).and_raise(OAuth2::Error, 'Token problem of some kind')
        allow(Rails.logger).to receive(:error)
      end

      it 'returns false' do
        expect(service.call).to be false
      end

      it 'logs the error message' do
        service.call
        expect(Rails.logger).to have_received(:error)
          .with(/Unable to submit PS xml for dissertation ID \d+: Token problem of some kind/).once
      end

      it 'notifies Honeybadger with the expected context' do
        service.call
        expect(Honeybadger).to have_received(:notify).with(instance_of(OAuth2::Error))
      end
    end
  end
end
