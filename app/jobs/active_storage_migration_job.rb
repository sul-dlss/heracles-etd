# frozen_string_literal: true

# Job to migrate legacy file attachments to ActiveStorage for a specific submission
# NOTE: This job can be removed once all legacy attachments have been migrated
class ActiveStorageMigrationJob < ApplicationJob
  queue_as :default

  def perform(submission_id)
    submission = Submission.find(submission_id)
    Honeybadger.context(submission:)
    legacy_submission = ActiveStorage::LegacySubmission.new(submission:)
    ActiveStorage::MigratorService.migrate(legacy_submission:)
  end
end
