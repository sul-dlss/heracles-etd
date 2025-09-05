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

    Honeybadger.context(submission:, folio_instance_hrid:)
    FolioClient.has_instance_status?(hrid: folio_instance_hrid,
                                     status_id: Settings.catalog.folio.status.cataloged_uuid)
  end

  private

  attr_reader :submission

  delegate :folio_instance_hrid, to: :submission
end
