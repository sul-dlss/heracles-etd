# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubmitToRegistrarService do
  describe '#call' do
    let(:submission) do
      create(:submission, :submittable, readerapproval: 'test', last_reader_action_at: Time.zone.now,
                                        readercomment: 'test', regapproval: 'test',
                                        last_registrar_action_at: Time.zone.now, regcomment: 'test')
    end

    before do
      allow(SignaturePageService).to receive(:call).and_return('spec/fixtures/files/dissertation-augmented.pdf')
      allow(PsRegistrarService).to receive(:call)
      allow(Settings).to receive(:dor_submit_ps_xml).and_return(true)
    end

    it 'updates the submission attributes, creates and attaches augmented PDF, and submits to the registrar' do
      expect { described_class.call(submission:) }
        .to change { submission.reload.submitted_at }.from(nil).to(instance_of(ActiveSupport::TimeWithZone))
        .and change(submission, :readerapproval).to(nil)
        .and change(submission, :last_reader_action_at).to(nil)
        .and change(submission, :readercomment).to(nil)
        .and change(submission, :regapproval).to(nil)
        .and change(submission, :last_registrar_action_at).to(nil)
        .and change(submission, :regcomment).to(nil)
      expect(submission.augmented_dissertation_file).to be_attached
      expect(submission.augmented_dissertation_file.filename.to_s).to eq('dissertation-augmented.pdf')
      expect(SignaturePageService).to have_received(:call).with(submission: submission)
      expect(PsRegistrarService).to have_received(:call).with(submission: submission)
    end

    context 'when an error occurs in SignaturePageService' do
      before do
        allow(SignaturePageService).to receive(:call).and_raise(SignaturePageService::Error, 'Signature page error')
        allow(Honeybadger).to receive(:notify)
      end

      it 'notifies Honeybadger' do
        described_class.call(submission:)
        expect(Honeybadger).to have_received(:notify).with(SignaturePageService::Error,
                                                           context: { dissertation_id: submission.dissertation_id })
        expect(PsRegistrarService).to have_received(:call).with(submission: submission)
      end
    end
  end
end
