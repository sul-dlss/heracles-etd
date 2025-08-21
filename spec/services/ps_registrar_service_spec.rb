# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PsRegistrarService do
  describe '#soap_message' do
    subject(:xml) { described_class.new(submission:).send(:soap_message) }

    let(:submission) do
      build(:submission, dissertation_id: '1234', title: 'some title', submitted_at: Time.zone.parse('2020-01-01'))
    end

    it 'uses the ERB template to build the message' do
      expect(xml).to match(/1234/)
      expect(xml).to match(/some title/)
    end
  end

  describe '#call' do
    subject(:result) { service.call }

    let(:service) { described_class.new(submission:) }
    let(:submission) { build(:submission, dissertation_id: '0001') }

    before do
      allow(Honeybadger).to receive(:notify)
      allow(service).to receive(:soap_message).and_return('My message')
    end

    context 'when the post succeeds' do
      before do
        stub_request(:post, 'http://registrar.example.edu/')
          .with(
            body: 'My message',
            headers: {
              'Authorization' => 'Basic Og==',
              'Content-Type' => 'text/xml;charset=UTF-8',
              'Soapaction' => 'STF_FEDORA_IN_MSG1.v1'
            }
          )
          .to_return(status: 200)
      end

      it 'returns true' do
        expect(result).to be true
        expect(Honeybadger).not_to have_received(:notify)
      end
    end

    context 'when the post fails with a 500' do
      before do
        stub_request(:post, 'http://registrar.example.edu/')
          .with(
            body: 'My message',
            headers: {
              'Authorization' => 'Basic Og==',
              'Content-Type' => 'text/xml;charset=UTF-8',
              'Soapaction' => 'STF_FEDORA_IN_MSG1.v1'
            }
          )
          .to_return(status: 500, body: 'Oh no!')
      end

      it 'returns false and notifies' do
        expect(result).to be false
        expect(Honeybadger).to have_received(:notify).with('Failed to submit PS XML for dissertation',
                                                           context: { dissertation_id: '0001', response: 'Oh no!' })
      end
    end

    context 'when the post raises' do
      before do
        allow(Faraday).to receive(:new).and_raise(StandardError.new('Network error'))
      end

      it 'returns false and notifies' do
        expect(result).to be false
        expect(Honeybadger).to have_received(:notify).with(StandardError,
                                                           context: { dissertation_id: '0001' })
      end
    end
  end
end
