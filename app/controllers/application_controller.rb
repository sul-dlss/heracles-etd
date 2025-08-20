# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActiveAdminConcern

  # Adds an after_action callback to verify that `authorize!` has been called.
  # See https://actionpolicy.evilmartians.io/#/rails?id=verify_authorized-hooks for how to skip.
  verify_authorized

  rescue_from ActionPolicy::Unauthorized, with: :deny_access

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # ActiveAdmin provides an arg when calling this method.
  def deny_access(_error = nil)
    render status: :unauthorized, html: 'You are unauthorized to see this'
  end

  private

  def current_user
    @current_user ||= User.from_request(request:)
  end
end
