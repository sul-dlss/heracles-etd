# frozen_string_literal: true

# Controller for ETD endpoints used by Peoplesoft to transfer data to the ETD system
class EtdsController < ApplicationController
  skip_verify_authorized only: %i[index create]
  before_action :authenticate, only: %i[index create]

  # GET /etds
  # only here for peoplesoft ping
  def index
    render html: 'OK'
  end

  # POST /etds
  # receives xml data from peoplesoft
  def create
    logger.info("RAW XML: #{request.raw_post}")

    nil if render_bad_request
  end

  attr_accessor :invalid_xml_message

  private

  def dissertation_id
    etd_params.expect(:dissertationid)
  end

  def readers
    etd_params.expect(:reader)
  end

  def etd_params
    params.expect(DISSERTATION: [:dissertationid, :title, :type, :readerapproval, :readercomment, :regapproval,
                                 :regcomment, :documentaccess, :schoolname, :degreeconfyr, :univid, :sunetid,
                                 :readeractiondttm, :regactiondttm, :degree, :name, :vpname, :career, :program,
                                 :plan, { subplan: %i[code __content__],
                                          reader: %i[sunetid name_prefix prefix name suffix type
                                                     univid readerrole finalreader] }])
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
end
