# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubmissionPoster do
  let(:submission) { create(:submission, :submitted) }

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
      instance_double(Faraday::Response, status:, body: response_json)
    end
    let(:response_json) { '{"response":{"status":"SUCCESS","message":"Updated the Dissertation data"}}' }
    let(:peoplesoft_base_url) { 'https://example.stanford.edu/peoplesoft' }
    let(:service) { described_class.new(submission:) }
    let(:status) { 200 }

    before do
      allow(Rails.logger).to receive(:info)
      allow(service).to receive(:response).and_return(fake_response)
      allow(Settings.peoplesoft).to receive(:base_url).and_return(peoplesoft_base_url)
      allow(submission).to receive(:prepare_to_submit!).and_call_original
    end

    it 'invokes Submission#prepare_to_submit!' do
      service.call
      expect(submission).to have_received(:prepare_to_submit!).once
    end

    it 'logs a message to indicate an update is being sent to PeopleSoft' do
      service.call
      expect(Rails.logger).to have_received(:info).with(/Submitting ETD update to PeopleSoft/).once
    end

    it 'returns nil' do
      expect(service.call).to be_nil
    end

    context 'when PeopleSoft URL is blank' do
      let(:peoplesoft_base_url) { '' }

      it 'raises a RuntimeError' do
        expect { service.call }.to raise_error(RuntimeError,
                                               'Cannot post submission because PeopleSoft base URL is blank')
      end
    end

    context 'when PeopleSoft is not enabled' do
      before do
        allow(Settings.peoplesoft).to receive(:enabled).and_return(false)
      end

      it 'does not call PeopleSoft' do
        service.call
        expect(submission).to have_received(:prepare_to_submit!).once
        expect(service).not_to have_received(:response)
      end
    end

    context 'when post returns a non-200 response' do
      let(:status) { 500 }

      it 'returns false' do
        expect { service.call }
          .to raise_error(RuntimeError, /Failed to post submission XML to PeopleSoft, received status/)
      end
    end

    context 'when an exception is raised' do
      before do
        allow(service).to receive(:response).and_raise(OAuth2::Error, 'Token problem of some kind')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error message and then raises the underlying exception' do
        expect { service.call }.to raise_error(OAuth2::Error)
        expect(Rails.logger).to have_received(:error)
          .with(/Unable to post submission XML to PeopleSoft for dissertation ID \d+: Token problem of some kind/).once
      end
    end
  end
end
