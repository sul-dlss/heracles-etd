# frozen_string_literal: true

# Service to check if a submission is cataloged in Folio
class FolioChecker
  def self.cataloged?(submission:)
    new(submission:).cataloged?
  end

  def initialize(submission:)
    @submission = submission
  end

  def cataloged?
    return false if folio_instance_hrid.blank?

    FolioClient.has_instance_status?(hrid: folio_instance_hrid,
                                     status_id: Settings.catalog.folio.status.cataloged_uuid)
  rescue FolioClient::ResourceNotFound => e
    Honeybadger.notify(
      "No matching instance found for #{folio_instance_hrid}",
      error_message: e.message,
      error_class: e.class
    )
    raise e
  end

  private

  attr_reader :submission

  delegate :folio_instance_hrid, to: :submission
end
