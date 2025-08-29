# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignaturePageService do
  let(:etd_type) { 'Thesis' }
  let(:submission) do
    create(:submission, :submittable, :with_readers, :with_advisors, :with_supplemental_files, etd_type:)
  end
  let(:temp_dir) { Dir.mktmpdir }
  let(:dissertation_path) { File.join(temp_dir, 'dissertation.pdf') }

  before do
    FileUtils.cp(file_fixture('dissertation.pdf'), dissertation_path)
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#call' do
    let(:augmented_dissertation_path) { described_class.call(submission:, dissertation_path:) }

    before do
      allow(FileUtils).to receive(:rm_f).and_call_original
    end

    it 'writes a PDF and cleans up after itself' do
      expect(File.exist?(augmented_dissertation_path)).to be true

      expect(FileUtils).to have_received(:rm_f).with(%r{#{Dir.tmpdir}/submission-#{submission.id}.+.pdf}).once
      expect(augmented_dissertation_path).to end_with('-augmented.pdf')
    end

    context 'with a dissertation-type submission' do
      let(:etd_type) { 'Dissertation' }

      # Don't bother cleaning up behavior here since it was already tested above
      it 'writes a PDF' do
        expect(File.exist?(augmented_dissertation_path)).to be true
      end
    end

    context 'when augmented PDF fails validation on write' do
      let(:fake_document) { HexaPDF::Document.new }

      before do
        allow(HexaPDF::Document).to receive(:open).with(anything).and_call_original
        allow(HexaPDF::Document).to receive(:open).with(dissertation_path).and_return(fake_document)
        allow(fake_document).to receive(:write).with(anything, optimize: true, validate: false).and_call_original
        allow(fake_document).to receive(:write).with(anything, optimize: true)
                                               .and_raise(HexaPDF::Error, 'Invalid table or header')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs a message and tries again once' do
        expect { augmented_dissertation_path }.not_to raise_error
        expect(Rails.logger).to have_received(:error).once.with(/Error writing augmented PDF/)
        expect(fake_document).to have_received(:write).twice
      end
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
        allow(Honeybadger).to receive(:context)
      end

      it 'raises an error' do
        expect { augmented_dissertation_path }.to raise_error(RuntimeError)
        expect(Honeybadger).to have_received(:context).with(submission:, dissertation_path: instance_of(String))
      end
    end
  end
end
