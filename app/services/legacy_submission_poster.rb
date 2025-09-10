# frozen_string_literal: true

# Post an XML representation of a submission to the Registrar via PeopleSoft (and legacy methodology)
class LegacySubmissionPoster
  def initialize(submission:)
    @submission = submission
  end

  # @raise [RuntimeError] if the PeopleSoft response is not successful, or if an exception is raised
  # @return [NilClass] return nil if request succeeds or if the service is disabled
  def call # rubocop:disable Metrics/AbcSize
    submission.prepare_to_submit!

    return unless Settings.peoplesoft.enabled

    Honeybadger.context(submission:, xml:)

    Rails.logger.info("Submitting ETD update to PeopleSoft: #{xml}")

    return if response.status == 200

    raise "Failed to post submission XML to PeopleSoft, received status '#{response.status}': #{response.body}"
  rescue StandardError => e
    Rails.logger.error(
      "Unable to post submission XML to PeopleSoft for dissertation ID #{submission.dissertation_id}: #{e.message}"
    )
    raise e # This will cause a Honeybadger notification to go out
  end

  private

  attr_reader :submission

  def response
    @response ||= client.post do |req|
      req.headers['SOAPAction'] = 'STF_FEDORA_IN_MSG1.v1'
      req.headers['Content-Type'] = 'text/xml;charset=UTF-8'
      req.body = xml
    end
  end

  def xml
    # The username, password, msg ivars are used in the template
    @username = Settings.ps_reg_username
    @password = Settings.ps_reg_password
    @msg = submission.to_peoplesoft_hash
    template = ERB.new(Rails.root.join('config/soap/ps_soap.xml.erb').read)
    template.result binding # binding is the current scope
  end

  def client
    @client ||= Faraday.new(url: Settings.ps_reg_endpoint) do |conn|
      conn.request :authorization, :basic, Settings.ps_reg_username, Settings.ps_reg_password
    end
  end
end
