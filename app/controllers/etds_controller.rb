# frozen_string_literal: true

# Controller for ETD endpoints used by Peoplesoft to transfer data to the ETD system
class EtdsController < ApplicationController
  skip_verify_authorized only: %i[index create]
  before_action :authenticate, only: %i[index create]
  before_action :set_submission, only: %i[create]

  attr_reader :invalid_xml_message, :submission

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
    ReaderService.assign_readers(submission:, readers:)
    render status: :created, html: "#{submission.druid} created"
  end

  private

  def dissertation_id
    etd_params.expect(:dissertationid)
  end

  def readers
    Reader.sorted_list(etd_params.expect(reader: [%i[sunetid name_prefix prefix name suffix type
                                                     univid readerrole finalreader]]))
  end

  def etd_params
    params.expect(DISSERTATION: [:dissertationid, :title, :type, :readerapproval, :readercomment, :regapproval,
                                 :regcomment, :documentaccess, :schoolname, :degreeconfyr, :univid, :sunetid,
                                 :readeractiondttm, :regactiondttm, :degree, :name, :vpname, :career, :program,
                                 :plan,
                                 { subplan: [%i[code __content__]],
                                   reader: [%i[sunetid name_prefix prefix name suffix type
                                               univid readerrole finalreader]] }])
  end

  def title
    etd_params[:title].gsub(/\s+/, ' ').strip
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

  def render_bad_request
    return if valid_xml?

    render status: :bad_request, html: invalid_xml_message

    true
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
    return if render_bad_request

    @submission = Submission.find_or_initialize_by(dissertation_id:, title:)
  end

  def submission_attributes # rubocop:disable Metrics/AbcSize
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
      # attrs[:degree] = EtdsHelper.normalize_degree(attrs.delete(:degree))
      # attrs[:ps_subplan] = attrs.dig(:subplan, :__content__) if attrs[:subplan]
      # attrs[:sub]
      # attrs[:provost] = attrs.delete(:vpname)
      # attrs[:name] = EtdsHelper.add_space_after_comma(attrs[:name
    end.compact
  end
end
