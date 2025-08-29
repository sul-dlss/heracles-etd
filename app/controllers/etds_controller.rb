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

    render_bad_request and return if error_message
  end

  private

  def dissertation_id
    params.require(:DISSERTATION).require(:dissertationid)
  end

  def etd_params
    params.require(:DISSERTATION)
          .permit(:title, :type, :readerapproval, :readercomment, :regapproval, :regcomment,
                  :documentaccess, :schoolname, :degreeconfyr, :univid, :sunetid,
                  :readeractiondttm, :regactiondttm, :degree, :name, :vpname,
                  :career, :program, :plan,
                  subplan: %i[code __content__],
                  reader: %i[sunetid name_prefix prefix name suffix type univid readerrole finalreader])
  rescue ActionDispatch::Http::Parameters::ParseError => e
    error_msg = error_message(error: e, request:)
    logger.error("Error parsing XML from Peoplesoft: #{error_msg}")
    # Honeybadger.notify(e, context: { dissertation_id:, xml: request.raw_post })
    render status: :internal_server_error, html: error_msg
  rescue ActionController::ParameterMissing => e
    error_msg = error_message(error: e, request:)
    logger.error("Data posted from registrar is invalid -- cannot proceed: #{error_msg}")
    # Honeybadger.notify(e, context: { xml: request.raw_post })
    render status: :bad_request, html: error_msg
  end

  def error_message(error:, request:)
    "Unable to process incoming dissertation: #{error.message}\n\n" \
      "Incoming XML:\n\n#{request.raw_post}"

    # return 'Attempting to post a dissertation without any xml' if blank_xml?
    # return 'Data posted from registrar is invalid -- cannot proceed' unless etd_params

    # 'Data posted from registrar is missing dissertationid -- cannot proceed' unless dissertation_id
  end

  # def blank_xml?
  #   request.env['RAW_POST_DATA'].nil? || request.env['RAW_POST_DATA'].strip == ''
  # end

  def render_bad_request
    render status: :bad_request, html: error_message
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
