# frozen_string_literal: true

module Marc
  # Orchestrates the generation of a stub MARC record, writing the record to the
  # catalog, and importing the catalog identifier for an ETD submission
  class StubRecordPipeline
    def self.run(...)
      new(...).run
    end

    # @param druid [String] the druid for the ETD submission for which to run the pipeline
    def initialize(druid:)
      @submission = Submission.find_by!(druid:)
    end

    # @return [void]
    def run
      unless submission.stub_record_written?
        record = StubRecordGenerator.generate(druid:)
        catalog_record_job_id = StubRecordWriter.write_to_catalog(druid:, record:)
        submission.update!(catalog_record_job_id:)
      end

      folio_instance_hrid = CatalogIdentifierImporter.import(submission:)
      Honeybadger.context(folio_instance_hrid:)

      # Update the submission item in SDR
      object_client.update(params: item_with_catalog_link(folio_instance_hrid:))
    end

    private

    attr_reader :submission

    delegate :druid, to: :submission

    def object_client
      @object_client ||= Dor::Services::Client.object(druid)
    end

    def item_with_catalog_link(folio_instance_hrid:)
      item = object_client.find
      item_hash = item.to_h
      item_hash[:identification][:catalogLinks] = [
        { catalog: 'folio', catalogRecordId: folio_instance_hrid, refresh: true }
      ]
      item.new(item_hash)
    end
  end
end
