# frozen_string_literal: true

module ActiveStorage
  # Service to handle migration of legacy file attachments to ActiveStorage
  # This service can be called multiple times safely
  class MigratorService
    WORKSPACE_DIR = '/opt/app/etd/workspace'

    def initialize(submission:)
      @submission = submission
    end

    attr_reader :submission

    private

    # Returns all submissions that do not have an ActiveStorage attachment for the dissertation file
    def legacy_submissions
      Submission.left_joins(:dissertation_file_attachment).where(active_storage_attachments: { id: nil })
    end

    # Generates SQL to find legacy attachments of a specific type for the current submission
    def legacy_attachment_sql(file_type)
      'SELECT * FROM attachments ' \
        'JOIN uploaded_files ON attachments.uploaded_file_id = uploaded_files.id ' \
        "WHERE attachments.submission_id = #{submission.id} " \
        "AND uploaded_files.type = '#{file_type}'"
    end

    def legacy_permission_files
      sql = legacy_attachment_sql('PermissionFile')
      ActiveRecord::Base.connection.execute(sql)
    end

    def legacy_supplemental_files
      sql = legacy_attachment_sql('SupplementalFile')
      ActiveRecord::Base.connection.execute(sql)
    end

    def legacy_dissertation_file
      sql = legacy_attachment_sql('DissertationFile')
      ActiveRecord::Base.connection.execute(sql)
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
