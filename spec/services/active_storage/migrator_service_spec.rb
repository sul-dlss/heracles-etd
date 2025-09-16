# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveStorage::MigratorService do
  let(:submission) { create(:submission) }

  describe '.migrate' do
    before do
      FileUtils.mkdir_p(File.join(Settings.file_uploads_root, submission.druid))
    end

    after do
      FileUtils.rm_r(File.join(Settings.file_uploads_root, submission.druid))
    end

    context 'when migrating a legacy ETD' do
      let(:legacy_dissertation_file) { submission.legacy_parts.find { |part| part.is_a?(LegacyDissertationFile) } }

      before do
        create(:attachment, :with_legacy_dissertation_file, submission:)

        submission.reload
        FileUtils.cp(file_fixture('dissertation.pdf'), legacy_dissertation_file.file_path)
        FileUtils.cp(file_fixture('dissertation-augmented.pdf'), legacy_dissertation_file.augmented_path)
      end

      context 'when all file types are attached and present' do
        let(:supplemental_file) { submission.legacy_parts.find { |part| part.is_a?(LegacySupplementalFile) } }
        let(:permission_file) { submission.legacy_parts.find { |part| part.is_a?(LegacyPermissionFile) } }

        before do
          create(:attachment, :with_legacy_supplemental_file, submission:)
          create(:attachment, :with_legacy_permission_file, submission:)

          submission.reload
          FileUtils.cp(file_fixture('supplemental_1.pdf'), supplemental_file.file_path)
          FileUtils.cp(file_fixture('permission_1.pdf'), permission_file.file_path)
        end

        it 'migrates successfully' do
          expect(submission.dissertation_file).not_to be_attached
          expect(submission.augmented_dissertation_file).not_to be_attached
          expect(submission.supplemental_files.count).to eq 0
          expect(submission.permission_files.count).to eq 0
          described_class.migrate(submission:)
          submission.reload
          expect(submission.dissertation_file).to be_attached
          expect(submission.augmented_dissertation_file).to be_attached
          expect(submission.supplemental_files.count).to eq 1
          expect(submission.permission_files.count).to eq 1
          expect(ActiveStorage::Attachment.count).to eq 4
        end
      end

      context 'when supplemental and permissions files are expected but not found on disk' do
        let(:supplemental_file) { submission.legacy_parts.find { |part| part.is_a?(LegacySupplementalFile) } }
        let(:permission_file) { submission.legacy_parts.find { |part| part.is_a?(LegacyPermissionFile) } }

        before do
          create(:attachment, :with_legacy_supplemental_file, submission:)
          create(:attachment, :with_legacy_permission_file, submission:)
          submission.reload
        end

        it 'migrates successfully' do
          expect(submission.dissertation_file).not_to be_attached
          expect(submission.augmented_dissertation_file).not_to be_attached
          expect(submission.supplemental_files.count).to eq 0
          expect(submission.permission_files.count).to eq 0
          described_class.migrate(submission:)
          submission.reload
          expect(submission.dissertation_file).to be_attached
          expect(submission.augmented_dissertation_file).to be_attached
          expect(submission.supplemental_files.count).to eq 0
          expect(submission.permission_files.count).to eq 0
          expect(ActiveStorage::Attachment.count).to eq 2
        end
      end

      context 'when only a dissertation file is attached and present' do
        it 'migrates successfully' do
          expect(submission.dissertation_file).not_to be_attached
          expect(submission.augmented_dissertation_file).not_to be_attached
          expect(submission.supplemental_files.count).to eq 0
          expect(submission.permission_files.count).to eq 0
          described_class.migrate(submission:)
          submission.reload
          expect(submission.dissertation_file).to be_attached
          expect(submission.augmented_dissertation_file).to be_attached
          expect(submission.supplemental_files.count).to eq 0
          expect(submission.permission_files.count).to eq 0
          expect(ActiveStorage::Attachment.count).to eq 2
        end
      end
    end

    context 'when the dissertation file is missing' do
      let(:supplemental_file) { submission.legacy_parts.find { |part| part.is_a?(LegacySupplementalFile) } }
      let(:permission_file) { submission.legacy_parts.find { |part| part.is_a?(LegacyPermissionFile) } }

      before do
        create(:attachment, :with_legacy_supplemental_file, submission:)
        create(:attachment, :with_legacy_permission_file, submission:)

        submission.reload
        FileUtils.cp(file_fixture('supplemental_1.pdf'), supplemental_file.file_path)
        FileUtils.cp(file_fixture('permission_1.pdf'), permission_file.file_path)
      end

      it 'raises an error and rolls back attaching any files' do
        expect { described_class.migrate(submission:) }.to raise_error(ActiveStorage::MigratorService::MissingDissertationFileError)
        expect(submission.dissertation_file).not_to be_attached
        expect(submission.augmented_dissertation_file).not_to be_attached
        expect(submission.supplemental_files.count).to eq 0
        expect(submission.permission_files.count).to eq 0
        expect(ActiveStorage::Attachment.count).to eq 0
      end
    end
  end
end
