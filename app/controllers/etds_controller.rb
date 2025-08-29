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

  def unwrapped_params
    @unwrapped_params ||= params.fetch('DISSERTATION', params)
  end

  def error_message
    return 'Attempting to post a dissertation without any xml' if blank_xml?

    'Data posted from registrar is invalid -- cannot proceed' if unwrapped_params.blank?
  end

  def blank_xml?
    request.env['RAW_POST_DATA'].nil? || request.env['RAW_POST_DATA'].strip == ''
  end

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
