# frozen_string_literal: true

# Post an XML representation of a submission to the Registrar via PeopleSoft
class SubmissionPoster
  def self.call(...)
    new(...).call
  end

  API_ENDPOINT = '/library/v1'

  def initialize(submission:)
    @submission = submission
  end

  # @raise [RuntimeError] if the PeopleSoft URL is blank, the PeopleSoft
  #   response is not successful, or if an exception is raised
  # @return [NilClass] nil if succeeds
  def call # rubocop:disable Metrics/AbcSize
    submission.prepare_to_submit!

    Honeybadger.context(submission:, xml:)

    raise 'Cannot post submission because PeopleSoft base URL is blank' if Settings.peoplesoft.base_url.blank?

    Rails.logger.info("Submitting ETD update to PeopleSoft: #{xml}")

    return if response.status == 200 && JSON.parse(response.body).dig('response', 'status') == 'SUCCESS'

    raise "Failed to post submission XML to PeopleSoft, received status '#{response.status}': #{response.body}"
  rescue StandardError => e
    Rails.logger.error(
      "Unable to post submission XML to PeopleSoft for dissertation ID #{submission.dissertation_id}: #{e.message}"
    )
    raise e # This will cause a Honeybadger notification to go out
  end

  private

  attr_reader :submission

  def client
    @client ||= OAuth2::Client.new(
      Settings.peoplesoft.client_id,
      Settings.peoplesoft.client_secret,
      site: Settings.peoplesoft.base_url,
      token_url: Settings.peoplesoft.token_url,
      connection_opts: { request: request_options }
    )
  end

  def xml
    @xml ||= SubmissionsController.render(:submit, locals: submission.to_peoplesoft_hash, formats: :xml)
  end

  def token
    @token ||= client.client_credentials.get_token.token
  end

  def connection
    @connection ||= Faraday.new(url: Settings.peoplesoft.base_url, request: request_options) do |conn|
      conn.request :authorization, :Bearer, token
      conn.adapter :net_http
    end
  end

  # Default timeouts were not long enough when testing
  def request_options
    { read_timeout: 300, timeout: 300 }
  end

  def response
    @response ||= connection.post(API_ENDPOINT, xml)
  end

  # def response
  #   @response ||= client.client_credentials.get_token.post(API_ENDPOINT, body: xml)
  # end
end
