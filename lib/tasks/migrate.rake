# frozen_string_literal: true

WORKSPACE_DIR = '/opt/app/etd/workspace'

namespace :migrate do
  desc 'Migrate legacy file attachments into ActiveStorage'
  # Usage: rake migrate:dissertation_files
  # Migration of dissertation files from legacy attachments to ActiveStorage
  # This can safely be re-run multiple times
  task dissertation_files: :environment do
    log_file = Rails.root.join('log/dissertation_file_migration.log')
    logger = Logger.new(log_file)
    logger.level = Logger::INFO

    workspace_dir = if Rails.env.development?
                      Rails.root.join('tmp/workspace')
                    else
                      WORKSPACE_DIR
                    end

    logger.info "Using workspace directory: #{workspace_dir}"

    Submission.left_joins(:dissertation_file_attachment).where(active_storage_attachments: { id: nil }).each do |submission|
      logger.info "Processing submission #{submission.id}, dissertation_id: #{submission.dissertation_id}, druid: #{submission.druid}"

      logger.info "Migrating permission files for submission #{submission.id}, dissertation_id: #{submission.dissertation_id}"

      # Migrate permission files first
      permission_sql = 'SELECT * FROM attachments ' \
                       'JOIN uploaded_files ON attachments.uploaded_file_id = uploaded_files.id ' \
                       "WHERE attachments.submission_id = #{submission.id} " \
                       "AND uploaded_files.type = 'PermissionFile'"

      results = ActiveRecord::Base.connection.execute(permission_sql)

      logger.info "No permission files found for submission #{submission.id}" if results.count.zero?

      results.each do |result|
        file_path = File.join(workspace_dir, submission.druid, result['file_name'])
        logger.info "Would attach permission file #{result['file_name']} with label '#{result['label']}' from path #{file_path} to submission #{submission.id}"
        permission_file = PermissionFile.new(submission:, description: result['label'])
        permission_file.file.attach(io: File.open(file_path), filename: result['file_name'])
        permission_file.save!
      rescue Errno::ENOENT => e
        logger.error "File not found: #{file_path} for submission #{submission.id}. Error: #{e.message}"
      end

      # Migrate supplemental files
      supplemental_sql = 'SELECT * FROM attachments ' \
                         'JOIN uploaded_files ON attachments.uploaded_file_id = uploaded_files.id ' \
                         "WHERE attachments.submission_id = #{submission.id} " \
                         "AND uploaded_files.type = 'SupplementalFile'"

      results = ActiveRecord::Base.connection.execute(supplemental_sql)

      logger.info "No supplemental files found for submission #{submission.id}" if results.count.zero?

      results.each do |result|
        file_path = File.join(workspace_dir, submission.druid, result['file_name'])
        logger.info "Would attach supplemental file #{result['file_name']} with label '#{result['label']}' from path #{file_path} to submission #{submission.id}"
        supplemental_file = SupplementalFile.new(submission:, description: result['label'])
        supplemental_file.file.attach(io: File.open(file_path), filename: result['file_name'])
        supplemental_file.save!
      rescue Errno::ENOENT => e
        logger.error "File not found: #{file_path} for submission #{submission.id}. Error: #{e.message}"
      end

      # Migrate dissertation file
      dissertation_sql = 'SELECT * FROM attachments ' \
                         'JOIN uploaded_files ON attachments.uploaded_file_id = uploaded_files.id ' \
                         "WHERE attachments.submission_id = #{submission.id} " \
                         "AND uploaded_files.type = 'DissertationFile'"

      results = ActiveRecord::Base.connection.execute(dissertation_sql)

      logger.info "No dissertation files found for submission #{submission.id}" if results.count.zero?

      results.each do |result|
        file_path = File.join(workspace_dir, submission.druid, result['file_name'])
        logger.info "Would attach dissertation file #{result['file_name']} with label '#{result['label']}' from path #{file_path} to submission #{submission.id}"
        dissertation_file = DissertationFile.new(submission:, description: result['label'])
        dissertation_file.file.attach(io: File.open(file_path), filename: result['file_name'])
        dissertation_file.save!
      rescue Errno::ENOENT => e
        logger.error "File not found: #{file_path} for submission #{submission.id}. Error: #{e.message}"
      end
    end
  end
end
