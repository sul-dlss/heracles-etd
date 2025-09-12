# frozen_string_literal: true

# Create stub MARC record for ETD
class CreateStubMarcRecordJob < RetriableJob
  queue_as :submit_marc

  def perform(druid)
    @druid = druid
    Honeybadger.context(druid:)

    record = Marc::StubRecordCreator.create(druid:)
    folio_instance_hrid = Marc::WriteStubRecord.send_to_folio(druid:, record:)

    # Add folio_instance_hrid to the submission
    submission.update(folio_instance_hrid:, ils_record_created_at: Time.zone.now)

    # Add catalog link to the DRO
    dro_with_catalog_link = add_catalog_link(folio_instance_hrid:)
    object_client.update(params: dro_with_catalog_link)
  end

  private

  attr_reader :druid

  def object_client
    @object_client ||= Dor::Services::Client.object(druid)
  end

  def submission
    Submission.find_by!(druid:)
  end

  def add_catalog_link(folio_instance_hrid:)
    dro = object_client.find
    dro_as_hash = dro.to_h
    dro_as_hash[:identification][:catalogLinks] = [
      { catalog: 'folio', catalogRecordId: folio_instance_hrid, refresh: true }
    ]
    dro.class.new(dro_as_hash)
  end
end
