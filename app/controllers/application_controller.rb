# frozen_string_literal: true

class ApplicationController < ActionController::Base
  USER_GROUPS_HEADER = 'eduPersonEntitlement'
  REMOTE_USER_HEADER = 'REMOTE_USER'
  ORCID_ID_HEADER =  'eduPersonOrcid'

  # Adds an after_action callback to verify that `authorize!` has been called.
  # See https://actionpolicy.evilmartians.io/#/rails?id=verify_authorized-hooks for how to skip.
  verify_authorized

  rescue_from ActionPolicy::Unauthorized, with: :deny_access

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def current_user
    @current_user ||= User.new(
      remote_user: request.env[REMOTE_USER_HEADER],
      groups: groups_from_request,
      orcid: orcid_from_request
    )
  end

  def deny_access
    render status: :unauthorized, html: 'You are unauthorized to see this'
  end

  # Returns the groups from shibboleth in production and the groups set in the
  # ROLES environment variable in development.
  def groups_from_request
    return request.env[USER_GROUPS_HEADER].split(';') if request.env[USER_GROUPS_HEADER]

    []
  end

  # Returns the ORCID from shibboleth in production and the ORCID set in the
  # ORCID environment variable in development.
  def orcid_from_request
    orcid = request.env[ORCID_ID_HEADER]
    return if orcid.nil? || orcid == '(null)'

    orcid
  end
end
