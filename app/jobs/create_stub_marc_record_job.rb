# frozen_string_literal: true

# Create stub MARC record for ETD
class CreateStubMarcRecordJob < RetriableJob
  queue_as :submit_marc

  def perform(druid)
    Honeybadger.context(druid:)
    Marc::StubRecordPipeline.run(druid:)
  end
end
