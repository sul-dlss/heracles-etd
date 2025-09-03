# frozen_string_literal: true

require 'resolv'

# Controller for ETD endpoints used by Peoplesoft to transfer data to the ETD system
class EtdsController < ApplicationController
  skip_verify_authorized only: %i[index create]
  before_action :authenticate, only: %i[index create], unless: proc { request_from_authorized_origin? }
  before_action :set_submission, only: %i[create]

  PHD_REGEX = /p\W*h\W*d/i
  ENG_REGEX = /^eng$/i

  attr_reader :invalid_xml_message, :message, :submission

  # GET /etds
  # only here for peoplesoft ping
  def index
    render html: 'OK'
  end

  # POST /etds
  # receives xml data from peoplesoft
  def create
    logger.info("RAW XML: #{request.raw_post}")

    return unless submission

    @submission = RegisterService.register(submission:)
    @submission.update!(submission_attributes)
    peoplesoft_actions
    # we regenerate signature pages in case new readers were added
    # SignaturePageService.regenerate_signature_page(submission)
    render_created
  end

  private

  def dissertation_id
    etd_params.expect(:dissertationid)
  end

  def etd_params
    params.expect(DISSERTATION: [:dissertationid, :title, :type, :readerapproval, :readercomment, :regapproval,
                                 :regcomment, :documentaccess, :schoolname, :degreeconfyr, :univid, :sunetid,
                                 :readeractiondttm, :regactiondttm, :degree, :name, :vpname, :career, :program,
                                 :plan,
                                 { sub: [%i[deadline]] },
                                 { subplan: [%i[code __content__]],
                                   reader: [%i[sunetid name_prefix prefix name suffix type
                                               univid readerrole finalreader]] }])
  end

  def title
    etd_params[:title].gsub(/\s+/, ' ').strip
  end

  def degree
    return 'Ph.D.' if PHD_REGEX.match?(etd_params[:degree])
    return 'Engineering' if ENG_REGEX.match?(etd_params[:degree])

    etd_params[:degree]
  end

  def peoplesoft_actions
    peoplesoft_service.new_reader_action(readers:, reader_action_attributes:)
    peoplesoft_service.new_registrar_action(registrar_action_attributes:)
  end

  def peoplesoft_service
    @peoplesoft_service ||= PeoplesoftService.new(submission:)
  end

  def readers
    Reader.sorted_list(etd_params.expect(reader: [%i[sunetid name_prefix prefix name suffix type
                                                     univid readerrole finalreader]]))
  end

  def reader_action_attributes
    {
      readerapproval: etd_params[:readerapproval],
      readercomment: etd_params[:readercomment],
      last_reader_action_at: etd_params[:readeractiondttm]&.in_time_zone(Settings.peoplesoft_timezone)
    }
  end

  def registrar_action_attributes
    {
      regapproval: etd_params[:regapproval],
      regcomment: etd_params[:regcomment],
      last_registrar_action_at: etd_params[:regactiondttm]&.in_time_zone(Settings.peoplesoft_timezone)
    }
  end

  def render_bad_request
    render status: :bad_request, html: invalid_xml_message
  end

  def render_created
    render status: :created, html: "#{submission.druid} #{message}"
  end

  # Authentication based on a allow list of server names and IP addresses
  def request_from_authorized_origin?
    begin
      remote_hostname = Resolv.getname(request.remote_addr).downcase
      return true if Settings.ps_servers.include?(remote_hostname)
    rescue Resolv::ResolvError
      return true if Settings.ps_ips.include?(request.remote_addr)
    end
    false
  end

  def authenticate
    http_basic_authenticate_or_request_with(
      name: Settings.dlss_admin,
      password: Settings.dlss_admin_pw,
      realm: 'Application',
      message: 'You are unauthorized to perform this action'
    )
  end

  def set_submission
    render_bad_request and return unless valid_xml?

    @submission = Submission.find_or_initialize_by(dissertation_id:, title:)
    @message = @submission.new_record? ? 'created' : 'updated'
  end

  # Translate the incoming XML data to attributes on the Submission model
  # Exclude reader and registrar actions which are handled separately
  def submission_attributes # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # Reader and Registratar actions are handled separately
    # so remove them from the attributes to be updated here
    etd_params.to_h.except(:dissertationid, :reader, :title,
                           :readerapproval, :readercomment, :readeractiondttm,
                           :regapproval, :regcomment, :regactiondttm).tap do |attrs|
      attrs[:dissertation_id] = dissertation_id
      attrs[:title] = title
      attrs[:etd_type] = attrs.delete(:type)
      attrs[:ps_career] = attrs.delete(:career)
      attrs[:ps_program] = attrs[:program]
      attrs[:department] = attrs.delete(:program)
      attrs[:ps_plan] = attrs[:plan]
      attrs[:major] = attrs.delete(:plan)
      attrs[:degree] = degree
      attrs[:ps_subplan] = attrs.delete(:subplan)[:__content__] if attrs[:subplan]
      attrs[:sub] = "deadline #{attrs.delete(:sub)[:deadline]}" if attrs[:sub]
      attrs[:provost] = attrs.delete(:vpname)
      attrs[:name] = attrs.delete(:name)&.gsub(/,(\S)/, ', \1')
    end.compact
  end

  def valid_xml?
    true if etd_params && dissertation_id && readers
  rescue StandardError => e
    error_msg = "Unable to process incoming dissertation: #{e.message}"
    @invalid_xml_message = "#{error_msg}\n\nIncoming XML:\n\n#{request.raw_post}"
    logger.error("Error parsing XML from Peoplesoft: #{invalid_xml_message}")
    Honeybadger.notify(error_msg, context: { xml: request.raw_post })
    false
  end
end
