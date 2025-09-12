# frozen_string_literal: true

module ActiveStorage
  # Service to handle migration of legacy file attachments to ActiveStorage
  # This service can be called multiple times safely
  class LegacySubmission
    def initialize(submission:)
      @submission = submission
    end

    attr_reader :submission

    delegate :id, :druid, to: :submission

    def permission_files
      sql = legacy_attachment_sql('PermissionFile')
      @permission_files ||= ActiveRecord::Base.connection.execute(sql)
    end

    def supplemental_files
      sql = legacy_attachment_sql('SupplementalFile')
      @supplemental_files ||= ActiveRecord::Base.connection.execute(sql)
    end

    def dissertation_file
      sql = legacy_attachment_sql('DissertationFile')
      @dissertation_file ||= ActiveRecord::Base.connection.execute(sql)
    end

    private

    # Generates SQL to find legacy attachments of a specific type for the current submission
    def legacy_attachment_sql(file_type)
      'SELECT * FROM attachments ' \
        'JOIN uploaded_files ON attachments.uploaded_file_id = uploaded_files.id ' \
        "WHERE attachments.submission_id = #{submission.id} " \
        "AND uploaded_files.type = '#{file_type}'"
    end
  end
end
