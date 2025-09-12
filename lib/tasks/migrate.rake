# frozen_string_literal: true

WORKSPACE_DIR = '/opt/app/etd/workspace'

namespace :migrate do
  desc 'Migrate legacy file attachments into ActiveStorage'
  # Usage: rake migrate:dissertation_files
  # Migration of dissertation files from legacy attachments to ActiveStorage
  # This can safely be re-run multiple times
  task dissertation_files: :environment do
    Submission.left_joins(:dissertation_file_attachment)
              .where(active_storage_attachments: { id: nil })
              .find_each do |submission|
      ActiveStorageMigrationJob.perform_later(submission.id, log_file.to_s)
    end
  end
end
