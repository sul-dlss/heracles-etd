# frozen_string_literal: true

# Job to update catalog status of ETDs and trigger accessioning when ready
class CatalogStatusJob < RetriableJob
  def perform
    Honeybadger.check_in(Settings.honeybadger_checkins.catalog_status)

    Submission.has_catalog_record_id.ils_record_not_updated.find_each do |submission|
      next unless FolioChecker.cataloged?(submission:)

      Submission.transaction do
        submission.update!(ils_record_updated_at: Time.zone.now)
        StartAccessionJob.perform_later(submission.druid)
      end
    end
  end
end
