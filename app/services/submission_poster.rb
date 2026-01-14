# frozen_string_literal: true

# Post an XML representation of a submission to the Registrar via PeopleSoft
class SubmissionPoster
  # @see #new and #call
  def self.call(...)
    new(...).call
  end

  API_ENDPOINT = '/library/v1'

  def initialize(submission:)
    @submission = submission
  end

  # @raise [RuntimeError] if the PeopleSoft response is not successful, or if an exception is raised
  # @return [NilClass] return nil if request succeeds or if the service is disabled
  def call # rubocop:disable Metrics/AbcSize
    submission.prepare_to_submit! do
      return unless Settings.peoplesoft.enabled

      Honeybadger.context(submission:, xml:)

      Rails.logger.info("Submitting ETD update to PeopleSoft: #{xml}")

      return if response.status == 200 && response.parsed.dig(:response, :status) == 'SUCCESS'

      raise "Failed to post submission XML to PeopleSoft, received status '#{response.status}': #{response.parsed}"
    rescue StandardError => e
      Rails.logger.error(
        "Unable to post submission XML to PeopleSoft for dissertation ID #{submission.dissertation_id}: #{e.message}"
      )
      raise e # This will cause a Honeybadger notification to go out
    end
  end

  private

  attr_reader :submission

  def xml
    @xml ||= SubmissionsController.render(:submit, locals: submission.to_peoplesoft_hash, formats: :xml)
  end

  def response
    @response ||= client.client_credentials.get_token.post(API_ENDPOINT, body: xml)
  end

  def client
    @client ||= OAuth2::Client.new(
      Settings.peoplesoft.client_id,
      Settings.peoplesoft.client_secret,
      site: Settings.peoplesoft.base_url,
      token_url: Settings.peoplesoft.token_url,
      connection_opts: { request: request_options }
    )
  end

  # Default timeouts were not long enough when testing
  def request_options
    { read_timeout: 300, timeout: 300 }
  end
end
