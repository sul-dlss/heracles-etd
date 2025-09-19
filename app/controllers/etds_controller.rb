# frozen_string_literal: true

require 'resolv'

# Controller for ETD endpoints used by Peoplesoft to transfer data to the ETD system
class EtdsController < ApplicationController
  skip_verify_authorized
  skip_before_action :verify_authenticity_token
  before_action :authenticate
  before_action :set_submission_params, only: :create

  attr_reader :submission_params

  # GET /etds
  # only here for peoplesoft ping
  def index
    render plain: 'OK'
  end

  # POST /etds
  # receives xml data from peoplesoft
  def create # rubocop:disable Metrics/AbcSize
    logger.info("RAW XML: #{request.raw_post}")

    return render status: :bad_request, plain: 'No dissertation input provided' unless submission

    Submission.transaction do
      submission.update!(**submission_params.slice(*submission_update_params), druid:)

      PeoplesoftService.update(submission:, submission_params:)

      submission.generate_and_attach_augmented_file!
    end

    render status: return_status, plain: "#{submission.druid} #{message}"
  end

  private

  def message
    new_submission? ? 'created' : 'updated'
  end

  def return_status
    new_submission? ? :created : :ok
  end

  def new_submission?
    @new_submission
  end

  def druid
    @druid ||= submission.druid || RegisterService.register(submission:).externalIdentifier
  end

  def submission_update_params
    %i[dissertation_id title etd_type ps_career ps_program department ps_plan
       major degree ps_subplan sub provost name sunetid]
  end

  # Authentication based on an allow list of server names and IP addresses
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
    case Honeybadger.config[:env]
    when 'qa', 'stage', 'test', 'development'
      http_basic_authenticate_or_request_with(
        name: Settings.dlss_admin,
        password: Settings.dlss_admin_pw,
        realm: 'Application',
        message: 'You are unauthorized to perform this action'
      )
    else # When HB env is UAT or prod
      request_from_authorized_origin? || deny_access
    end
  end

  def set_submission_params
    @submission_params = Registrar::SubmissionInputParser.parse(**Hash.from_xml(request.raw_post)&.deep_symbolize_keys)
  rescue StandardError => e
    Honeybadger.notify('Error processing dissertation input',
                       context: { xml: request.raw_post },
                       error_message: e.message,
                       error_class: e.class,
                       backtrace: e.backtrace)
    logger.error("Error processing dissertation input (see Honeybadger for details): #{request.raw_post}")

    render status: :bad_request, plain: 'Error processing dissertation input'
  end

  def submission
    @submission ||= Submission.find_or_initialize_by(dissertation_id: submission_params[:dissertation_id],
                                                     title: submission_params[:title]).tap do |etd|
      # Record early whether we're dealing with a brand new ETD or one that was
      # already in the DB. We can't rely on checking this later since some
      # operations in #create will persist the ETD between now and when we care
      # about whether this is new or not, which would make every ETD look like a
      # not new record.
      @new_submission = etd.new_record?
    end
  end
end
