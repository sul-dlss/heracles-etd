# frozen_string_literal: true

# Service for posting submission information to PeopleSoft
class PsRegistrarService
  def self.call(...)
    new(...).call
  end

  PEOPLESOFT_API_ENDPOINT = '/library/v1'

  def initialize(submission:)
    @submission = submission
  end

  # @return [Boolean] true if succeeds
  def call # rubocop:disable Metrics/AbcSize
    Honeybadger.context(dissertation_id: @submission.dissertation_id, xml:)

    return false if Settings.peoplesoft.base_url.blank?

    Rails.logger.info("Submitting ETD update to PeopleSoft: #{xml}")

    return true if response.status == 200

    Honeybadger.notify('Failed to submit PS XML for dissertation', context: { response: response.parsed })
    false
  rescue StandardError => e
    Rails.logger.error("Unable to submit PS xml for dissertation ID #{submission.dissertation_id}: #{e.message}")
    Honeybadger.notify(e)
    false
  end

  private

  attr_reader :submission

  def client
    @client ||= OAuth2::Client.new(
      Settings.peoplesoft.client_id,
      Settings.peoplesoft.client_secret,
      site: Settings.peoplesoft.base_url,
      token_url: Settings.peoplesoft.token_url
    )
  end

  def xml
    @xml ||= SubmissionsController.render(:submit, locals: submission.to_peoplesoft_hash, formats: :xml)
  end

  def response
    @response ||= client.client_credentials.get_token.post(PEOPLESOFT_API_ENDPOINT, body: xml)
  end
end
