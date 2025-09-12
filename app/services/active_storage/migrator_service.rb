# frozen_string_literal: true

module ActiveStorage
  # Service to handle migration of legacy file attachments to ActiveStorage
  # This service can be called multiple times safely
  class MigratorService
    WORKSPACE_DIR = '/opt/app/etd/workspace'

    def self.migrate_all(logger:)
      new(logger: logger).migrate_all
    end

    def initialize(logger:)
      @logger = logger
    end

    attr_reader :logger

    def migrate_all
      logger.info "Starting migration of legacy attachments at #{Time.current}"
      logger.info "Using workspace directory: #{WORKSPACE_DIR}"
      logger.info "Found #{legacy_submissions.count} submissions to process"
      legacy_submissions.each do |legacy_submission|
        logger.info "Processing submission #{legacy_submission.id}, dissertation_id: #{legacy_submission.druid}"
        # Migrate permission files first
        # Permission files
        if legacy_submission.permission_files.none?
          logger.info "No permission files found for submission #{legacy_submission.id}"
        end
      end
    end

    private

    # Returns all submissions that do not have an ActiveStorage attachment for the dissertation file
    def legacy_submissions
      @legacy_submissions ||= Submission.left_joins(:dissertation_file_attachment)
                                        .where(active_storage_attachments: { id: nil })
                                        .map { |submission| ActiveStorage::LegacySubmission.new(submission:) }
    end

    def legacy_file_path(file_name)
      File.join(WORKSPACE_DIR, submission.druid, file_name)
    end

    def attach_file(file_record, file_path)
      file_record.file.attach(io: File.open(file_path), filename: file_name)
    rescue Errno::ENOENT => e
      logger.error "File not found: #{file_path} for submission #{submission.id}. Error: #{e.message}"
    end
  end
end
