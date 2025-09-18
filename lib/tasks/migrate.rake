# frozen_string_literal: true

namespace :migrate do
  desc 'Migrate legacy file attachments into ActiveStorage'
  # Usage: rake migrate:dissertation_files
  # Migration of dissertation files from legacy attachments to ActiveStorage
  # This can safely be re-run multiple times
  task dissertation_files: :environment do
    error_logger = Logger.new(Rails.root.join('log/migration_errors.log'))
    error_logger.level = Logger::Severity::ERROR

    puts 'Starting migration of legacy dissertation files to ActiveStorage...'

    # This selects all submissions that have any legacy parts and do not yet have an
    # ActiveStorage attached dissertation file
    migratable_submissions = Submission.where.associated(:legacy_parts).distinct
                                       .left_joins(:dissertation_file_attachment)
                                       .where(active_storage_attachments: { id: nil })
    submission_count = migratable_submissions.count
    submission_counter = 1
    failure_count = 0

    puts "Found #{submission_count} submissions with legacy dissertation files to migrate."

    migratable_submissions.order(created_at: :desc).each do |submission|
      next unless submission.legacy_parts.any?

      puts "#{submission_counter}/#{submission_count}: Migrating legacy submission attachments for " \
           "#{submission.dissertation_id} (#{submission.druid})"

      submission_counter += 1
      ActiveStorage::MigratorService.migrate(submission: submission)
    rescue StandardError => e
      puts "Error migrating submission #{submission.druid} (#{submission.dissertation_id}): #{e.message}"
      error_logger.error "FAILED: #{submission.dissertation_id} (#{submission.druid})\n #{e.message}"
      failure_count += 1
      next
    end

    puts "Migration complete with #{failure_count} failures. See log/migration_errors.log for details."
  end

  desc 'Remove legacy parts from submissions after migration'
  task remove_legacy_parts: :environment do
    puts 'Starting removal of legacy parts from submissions...'

    Submission.where.associated(:legacy_parts).distinct.each do |submission|
      puts "Removing legacy parts from submission #{submission.dissertation_id} (#{submission.druid})"
      submission.legacy_parts.each do |part|
        case part
        when LegacySupplementalFile
          next unless submission.supplemental_files.any? { |sf| sf.blob.filename == part.file_name }

          puts "  Deleting legacy supplemental file at #{part.file_name}"
        when LegacyPermissionFile
          next unless submission.permission_files.any? { |pf| pf.blob.filename == part.file_name }

          puts "  Deleting legacy permission file at #{part.file_name}"
        when LegacyDissertationFile
          next unless submission.dissertation_file.attached?
          next unless submission.dissertation_file.blob.filename == part.file_name

          puts "  Deleting legacy dissertation file at #{part.file_name} (no active dissertation attached)"
        else
          puts "  Unknown legacy part type: #{part.class.name} for file #{part.file_name}"
          next
        end
        part.destroy!
      end
    end
    puts 'Removal of legacy parts complete.'
  end
end
