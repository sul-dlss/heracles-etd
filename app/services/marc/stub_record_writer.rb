# frozen_string_literal: true

module Marc
  # Writes a stub MARC record to the catalog
  class StubRecordWriter
    attr_reader :druid, :record

    def self.write_to_catalog(...)
      new(...).write_to_catalog
    end

    # @param druid [String] druid for MARC record being written
    # @param record [MARC::Record] record MARC from the submission
    def initialize(druid:, record:)
      @druid = druid
      @record = record
    end

    # Send MARC record to catalog via data import API
    #
    # @raise [RuntimeError] if the import operation fails or if the import times out before completion
    # @return [String] the data import job execution ID if the operation succeeded
    def write_to_catalog # rubocop:disable Metrics/AbcSize
      import_result = data_importer.wait_until_complete(
        wait_secs: Settings.catalog.folio.import.wait_seconds,
        timeout_secs: Settings.catalog.folio.import.timeout_seconds,
        max_checks: Settings.catalog.folio.import.max_checks
      )

      raise "Error writing stub MARC record for #{druid}: see Folio import log for job #{data_importer.job_execution_id}" if import_result.failure? # rubocop:disable Layout/LineLength

      data_importer.job_execution_id
    end

    private

    def data_importer
      @data_importer ||= FolioClient.data_import(
        records: [record],
        job_profile_id: Settings.catalog.folio.marc_job_profile_uuid,
        job_profile_name: Settings.catalog.folio.marc_job_name
      )
    rescue FolioClient::Error => e
      Rails.logger.error("#{e.class}: #{e.message}. Error sending stub MARC record to FOLIO for #{druid}")
      Honeybadger.context(druid:)
      raise e
    end

    def submission
      Submission.find_by!(druid:)
    end
  end
end
