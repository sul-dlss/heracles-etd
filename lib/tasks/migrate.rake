# frozen_string_literal: true

namespace :migrate do
  desc 'Migrate legacy file attachments into ActiveStorage'
  # Usage: rake migrate:dissertation_files
  # Migration of dissertation files from legacy attachments to ActiveStorage
  # This can safely be re-run multiple times
  task dissertation_files: :environment do
    LegacyDissertationFile.find_each do |dissertation_file|
      next if dissertation_file.submissions.blank?
      next if dissertation_file.submissions.first.dissertation_file.attached?

      ActiveStorageMigrationJob.perform_later(dissertation_file.id)
    end
  end
end
