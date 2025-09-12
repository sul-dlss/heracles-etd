# frozen_string_literal: true

module ActiveStorage
  # Class to attach legacy file attachments to the current Submission model
  class LegacySubmission
    def initialize(submission:)
      @submission = submission
    end

    attr_reader :submission

    delegate :id, :druid, :dissertation_id, to: :submission

    def permission_files
      sql = legacy_attachment_sql('PermissionFile')
      @permission_files ||= fetch_legacy_attachments(sql)
    end

    def supplemental_files
      sql = legacy_attachment_sql('SupplementalFile')
      @supplemental_files ||= fetch_legacy_attachments(sql)
    end

    def dissertation_file
      sql = legacy_attachment_sql('DissertationFile')
      @dissertation_file ||= fetch_legacy_attachments(sql).first
    end

    # The legacy augmented dissertation file is derived from the main dissertation file
    def augmented_dissertation_file
      return if dissertation_file.blank?

      {
        file_path: dissertation_file[:file_path].sub(/\.pdf\z/, '-augmented.pdf'),
        file_name: dissertation_file[:file_name].sub(/\.pdf\z/, '-augmented.pdf')
      }
    end

    private

    # param [string] sql - SQL to find legacy attachments
    # returns [array<hash>] - Array of hashes with keys :file_path, :file_name, :label
    # Executes the provided SQL to find legacy attachments and returns
    # an array of hashes with necessary file information
    def fetch_legacy_attachments(sql)
      ActiveRecord::Base.connection.execute(sql).map do |result|
        {
          file_path: legacy_file_path(file_name: result['file_name']),
          file_name: result['file_name'],
          label: result['label']
        }
      end
    end

    # param [string] file_type - 'PermissionFile', 'SupplementalFile', or 'DissertationFile'
    # returns [string] - SQL to find legacy attachments
    # Generates SQL to find legacy attachments of a specific type for the current submission
    def legacy_attachment_sql(file_type)
      'SELECT * FROM attachments ' \
        'JOIN uploaded_files ON attachments.uploaded_file_id = uploaded_files.id ' \
        "WHERE attachments.submission_id = #{id} " \
        "AND uploaded_files.type = '#{file_type}'"
    end

    def legacy_file_path(file_name:)
      File.join(workspace_dir, druid, file_name)
    end

    def workspace_dir
      Rails.env.development? ? Rails.root.join('tmp/workspace') : Settings.file_uploads_root
    end
  end
end
