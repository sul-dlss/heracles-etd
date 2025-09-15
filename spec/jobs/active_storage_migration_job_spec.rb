# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveStorageMigrationJob do
  subject(:job) { described_class.new(dissertation_file.id) }

  let(:submission) { create(:submission) }
  let(:dissertation_file) { submission.legacy_parts.find { |part| part.is_a?(LegacyDissertationFile) } }

  before do
    create(:attachment, :with_legacy_dissertation_file, submission:)
    FileUtils.mkdir_p(File.dirname(dissertation_file.file_path))
  end

  after do
    FileUtils.rm_r(File.dirname(File.join(Settings.file_uploads_root, submission.druid)))
  end

  describe '.perform' do
    context 'when migrating a legacy ETD successfully' do
      before do
        FileUtils.cp(file_fixture('dissertation.pdf'), dissertation_file.file_path)
        FileUtils.cp(file_fixture('dissertation-augmented.pdf'), dissertation_file.augmented_path)
      end

      it 'attaches the file to the submission as ActivStorage attachments' do
        expect(submission.dissertation_file).not_to be_attached
        expect(submission.augmented_dissertation_file).not_to be_attached
        job.perform_now
        submission.reload
        expect(submission.dissertation_file).to be_attached
        expect(submission.augmented_dissertation_file).to be_attached
      end
    end

    context 'when migrating a legacy ETD fails' do
      before do
        allow(Honeybadger).to receive(:notify)
      end

      it 'does not attach the files to the submission as ActivStorage attachments' do
        expect(submission.dissertation_file).not_to be_attached
        expect(submission.augmented_dissertation_file).not_to be_attached
        expect { job.perform_now }.to raise_error(Errno::ENOENT)
        submission.reload
        expect(submission.dissertation_file).not_to be_attached
        expect(submission.augmented_dissertation_file).not_to be_attached
        expect(Honeybadger).to have_received(:notify).with(instance_of(Errno::ENOENT), anything).once
      end
    end
  end
end
