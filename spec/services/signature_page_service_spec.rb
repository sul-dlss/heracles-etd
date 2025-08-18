# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignaturePageService do
  let(:submission) { create(:submission, :submittable, :with_readers, :with_advisors) }

  let(:temp_dir) { Dir.mktmpdir }

  let(:dissertation_path) { File.join(temp_dir, 'dissertation.pdf') }

  before do
    FileUtils.cp('spec/fixtures/files/dissertation.pdf', dissertation_path)
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#call' do
    let(:augmented_dissertation_path) { described_class.call(submission:, dissertation_path:) }

    before do
      allow(FileUtils).to receive(:rm_f).and_call_original
    end

    it 'writes a PDF' do
      expect(File.exist?(augmented_dissertation_path)).to be true

      expect(FileUtils).to have_received(:rm_f).with(%r{#{Dir.tmpdir}/submission-#{submission.id}.+.pdf}).once
      expect(augmented_dissertation_path).to end_with('-augmented.pdf')
    end

    context 'when the dissertation file is missing' do
      it 'raises an error' do
        expect do
          described_class.call(submission:,
                               dissertation_path: 'missing.pdf')
        end.to raise_error(SignaturePageService::Error)
      end
    end

    context 'when an error is raised' do
      before do
        allow(HexaPDF::Document).to receive(:open).and_raise(RuntimeError, 'informative error message')
        allow(Honeybadger).to receive(:notify)
        allow(Honeybadger).to receive(:context)
      end

      it 'raises an error' do
        expect { augmented_dissertation_path }.to raise_error(SignaturePageService::Error)
        expect(Honeybadger).to have_received(:context).with(submission:)
        expect(Honeybadger).to have_received(:notify).with(instance_of(RuntimeError))
      end
    end
  end
end
