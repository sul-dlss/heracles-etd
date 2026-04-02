# frozen_string_literal: true

module Marc
  # Waits for catalog identifier to be assigned and returns it
  class CatalogIdentifierImporter
    def self.import(...)
      new(...).import
    end

    # @param submission [Submission] the ETD submission for which to import the catalog identifier
    def initialize(submission:)
      @submission = submission
    end

    # @return [String] the catalog identifier (Folio instance HRID) imported for the submission
    def import # rubocop:disable Metrics/AbcSize
      Honeybadger.context(job_execution_id: catalog_record_job_id)

      raise "Error importing instance HRID: #{job_status.instance_hrids.failure}" if job_status.instance_hrids.failure?

      job_status.instance_hrids.value!.first.tap do |folio_instance_hrid|
        submission.update!(folio_instance_hrid:, ils_record_created_at: Time.zone.now)
      end
    end

    private

    attr_reader :submission

    delegate :catalog_record_job_id, to: :submission

    def job_status
      @job_status ||= FolioClient::JobStatus.new(job_execution_id: catalog_record_job_id)
    end
  end
end
