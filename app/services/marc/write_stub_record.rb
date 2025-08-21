# frozen_string_literal: true

module Marc
  # Writes a stub marc record to the ILS catalog and returns the catalog assigned id or raises an error
  class WriteStubRecord
    attr_reader :druid, :record

    def self.output_file!(druid:, record:)
      new(druid:, record:).output_file!
    end

    def self.send_to_folio(druid:, record:)
      new(druid:, record:).send_to_folio
    end

    # @param druid [String] druid for marc record being written
    # @param record [MARC::Record] record Marc from the Etd
    def initialize(druid:, record:)
      @druid = druid
      @record = record
    end

    # Write MARC record to latest working directory
    def output_file!
      FileUtils.mkdir_p(output_directory)

      File.open(File.join(output_directory, "#{druid.tr(':', '_')}.marc"), 'w') do |f|
        writer = MARC::Writer.new(f)
        writer.write(record)
      end
    end

    # Send MARC record to folio
    def send_to_folio # rubocop:disable Metrics/AbcSize
      data_importer
        .wait_until_complete(
          wait_secs: Settings.catalog.folio.import.wait_seconds,
          timeout_secs: Settings.catalog.folio.import.timeout_seconds,
          max_checks: Settings.catalog.folio.import.max_checks
        )
        .tap do |result|
        return data_importer.instance_hrids.value!.first if result.success?

        raise "Record import failed.  See the import log in Folio for #{data_importer.job_execution_id} for more information. #{druid}" # rubocop:disable Layout/LineLength
      end
    end

    private

    def data_importer # rubocop:disable Metrics/AbcSize
      @data_importer ||= FolioClient.data_import(
        records: [record],
        job_profile_id: Settings.catalog.folio.marc_job_profile_uuid,
        job_profile_name: Settings.catalog.folio.marc_job_name
      )
    rescue FolioClient::ResourceNotFound => e
      Rails.logger.error("#{e.class}: #{e.message}. Error sending stub MARC record to FOLIO for #{druid}")
      Honeybadger.notify(
        'Error sending stub MARC record to FOLIO.',
        error_message: e.message,
        error_class: e.class,
        context: { druid: }
      )
      raise e
    end

    # The directory we will save the stub marc record to
    def output_directory
      File.join(Settings.marc_workspace, Time.zone.now.strftime('%Y%m%d'))
    end
  end
end
