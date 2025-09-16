# frozen_string_literal: true

module ActiveStorage
  # Service to handle migration of legacy file attachments to ActiveStorage
  # This service can be called multiple times safely
  class MigratorService
    class MissingDissertationFileError < StandardError; end

    def self.migrate(submission:)
      new(submission:).migrate
    end

    def initialize(submission:)
      @submission = submission
    end

    attr_reader :submission

    delegate :legacy_parts, to: :submission

    def migrate
      submission.transaction do
        migrate_permission_files
        migrate_supplemental_files
        migrate_dissertation_file
        submission.save!
      end
    end

    private

    # Migrate permission files first
    # Permission files
    def legacy_permission_files
      legacy_parts.select { |part| part.is_a?(LegacyPermissionFile) }
    end

    def migrate_permission_files
      return if legacy_permission_files.none?

      legacy_permission_files.map { |file| migrate_file_attachment(file_type: PermissionFile, file:) }
    end

    # Migrate supplemental files
    def legacy_supplemental_files
      legacy_parts.select { |part| part.is_a?(LegacySupplementalFile) }
    end

    def migrate_supplemental_files
      return if legacy_supplemental_files.none?

      legacy_supplemental_files.map { |file| migrate_file_attachment(file_type: SupplementalFile, file:) }
    end

    # Migrate dissertation file
    def legacy_dissertation_file
      legacy_parts.find { |part| part.is_a?(LegacyDissertationFile) }
    end

    def migrate_dissertation_file
      attach_augmented_dissertation_file
      attach_dissertation_file
    end

    def attach_dissertation_file
      raise MissingDissertationFileError unless legacy_dissertation_file

      # Attaches the dissertation file to the submission
      submission.dissertation_file.attach(io: File.open(legacy_dissertation_file.file_path),
                                          filename: legacy_dissertation_file.file_name)
    end

    def attach_augmented_dissertation_file
      return unless legacy_dissertation_file

      # Attaches the augmented dissertation file to the submission
      submission.augmented_dissertation_file.attach(io: File.open(legacy_dissertation_file.augmented_path),
                                                    filename: legacy_dissertation_file.augmented_file_name)
    end

    # This attempts to attach a file and logs an error if it fails
    # but continues processing other files as this is only used for
    # the optional Permission and Supplemental files
    def migrate_file_attachment(file_type:, file:)
      file_record = file_type.new(submission:, description: file.label)
      file_record.file.attach(io: File.open(file.file_path), filename: file.file_name)
    rescue StandardError => e
      Rails.logger.error "Failed to migrate #{file.file_name} for #{submission.druid}: #{e.message}"
      file_record.destroy
    end
  end
end
