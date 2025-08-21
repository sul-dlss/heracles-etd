# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubmitToRegistrarService do
  let(:submission) { build(:submission, :submittable) }

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
    subject(:service) { described_class.new(submission:) }

    let(:augmented_dissertation_path) { file_fixture('dissertation-augmented.pdf') }
    let(:now) { Time.zone.now }

    before do
      allow(Time.zone).to receive(:now).and_return(now)
      allow(PsRegistrarService).to receive(:call)
      allow(SignaturePageService).to receive(:call).and_return(augmented_dissertation_path)
    end

    it 'sets the submitted_at property on the submission' do
      expect { service.call }.to change(submission, :submitted_at).from(nil).to(now)
    end

    %i[readerapproval last_reader_action_at readercomment regapproval last_registrar_action_at
       regcomment].each do |property|
      it "clears the #{property} property on the submission" do
        expect { service.call }.to change { submission.public_send(property) }.to(nil)
      end
    end

    it 'invokes the SignaturePageService to generate the augmented dissertation file' do
      service.call
      expect(SignaturePageService).to have_received(:call).once.with(submission:)
    end

    it 'attaches the augmented dissertation file to the submission' do
      expect { service.call }.to change { submission.augmented_dissertation_file.attached? }
        .from(false).to(true)
    end

    it 'calls the peoplesoft registrar service' do
      service.call
      expect(PsRegistrarService).to have_received(:call).once
    end

    context 'when the SignaturePageService raises an error' do
      before do
        allow(SignaturePageService).to receive(:call).and_raise(SignaturePageService::Error, 'PDF could not generate!')
        allow(Honeybadger).to receive(:notify)
      end

      it 'notifies Honeybadger' do
        service.call
        expect(Honeybadger).to have_received(:notify).once.with(instance_of(SignaturePageService::Error),
                                                                context: {
                                                                  dissertation_id: submission.dissertation_id
                                                                })
      end
    end
  end
end
