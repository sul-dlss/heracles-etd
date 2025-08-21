# frozen_string_literal: true

# Service for posting submission information to PeopleSoft
class PsRegistrarService
  def self.call(...)
    PsRegistrarService.new(...).call
  end

  def initialize(submission:)
    @submission = submission
  end

  # @return [Boolean] true if succeeds
  def call # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    conn = Faraday.new(url: Settings.ps_reg_endpoint)
    conn.request :authorization, :basic, Settings.ps_reg_username, Settings.ps_reg_password

    response = conn.post do |req|
      req.headers['SOAPAction'] = 'STF_FEDORA_IN_MSG1.v1'
      req.headers['Content-Type'] = 'text/xml;charset=UTF-8'
      req.body = soap_message
    end

    unless response.status == 200
      Honeybadger.notify('Failed to submit PS XML for dissertation',
                         context: { dissertation_id: @submission.dissertation_id, response: response.body })
      return false
    end
    true
  rescue StandardError => e
    Honeybadger.notify(e, context: { dissertation_id: @submission.dissertation_id })
    false
  end

  private

  attr_reader :submission

  def to_ps_submit_hash
    {
      dissertation_id: submission.dissertation_id,
      title: submission.title,
      type: submission.etd_type,
      timestamp: submission.submitted_at.strftime('%m/%d/%Y %H:%M:%S'),
      purl: submission.purl
    }
  end

  def soap_message
    # The username, password, msg ivars are used in the template
    @username = Settings.ps_reg_username
    @password = Settings.ps_reg_password
    @msg = to_ps_submit_hash
    Rails.logger.info("Sending submitted ETD info to PS:\n #{@msg.inspect}")
    template = ERB.new(Rails.root.join('app', 'views', 'soap', "ps_soap_#{Settings.ps_env}.xml.erb").read)
    template.result binding # binding is the current scope
  end
end
