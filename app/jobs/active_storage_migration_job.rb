# frozen_string_literal: true

# Job to migrate legacy file attachments to ActiveStorage for a specific submission
# NOTE: This job can be removed once all legacy attachments have been migrated
class ActiveStorageMigrationJob < ApplicationJob
  queue_as :default

  def perform(legacy_dissertation_file_id)
    dissertation_file = LegacyDissertationFile.find(legacy_dissertation_file_id)
    Honeybadger.context(submission: dissertation_file.submissions.first)
    ActiveStorage::MigratorService.migrate(dissertation_file:)
  end
end
