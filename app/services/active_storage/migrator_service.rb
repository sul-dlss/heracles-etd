# frozen_string_literal: true

module ActiveStorage
  # Service to handle migration of legacy file attachments to ActiveStorage
  # This service can be called multiple times safely
  class MigratorService
    def self.migrate(legacy_submission:)
      new(legacy_submission:).migrate
    end

    def initialize(legacy_submission:)
      @legacy_submission = legacy_submission
    end

    attr_reader :legacy_submission

    delegate :submission, :permission_files, :supplemental_files,
             :dissertation_file, :augmented_dissertation_file, to: :legacy_submission

    def migrate
      migrate_permission_files
      migrate_supplemental_files
      migrate_dissertation_file
    end

    private

    # Migrate permission files first
    # Permission files
    def migrate_permission_files
      return if permission_files.none?

      permission_files.map { |file_params| migrate_file_attachment(file_type: PermissionFile, file_params:) }
    end

    # Migrate supplemental files
    def migrate_supplemental_files
      return if supplemental_files.none?

      supplemental_files.map { |file_params| migrate_file_attachment(file_type: SupplementalFile, file_params:) }
    end

    # Migrate dissertation file
    def migrate_dissertation_file
      return if dissertation_file.blank?

      attach_augmented_dissertation_file
      attach_dissertation_file
    end

    def attach_dissertation_file
      # Attaches the dissertation file to the submission
      submission.dissertation_file.attach(io: File.open(dissertation_file[:file_path]),
                                          filename: dissertation_file[:file_name])
    end

    def attach_augmented_dissertation_file
      # Attaches the augmented dissertation file to the submission
      submission.augmented_dissertation_file.attach(io: File.open(augmented_dissertation_file[:file_path]),
                                                    filename: augmented_dissertation_file[:file_name])
    end

    def migrate_file_attachment(file_type:, file_params:)
      file_record = file_type.new(submission:, description: file_params[:label])
      file_record.file.attach(io: File.open(file_params[:file_path]), filename: file_params[:file_name])
      file_record.save!
    end
  end
end
