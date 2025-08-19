# frozen_string_literal: true

# Concern containing all ActiveAdmin-related functionality
module ActiveAdminConcern
  extend ActiveSupport::Concern
  include ActionPolicy::Behaviour

  # Action Policy requires authorization. For ActiveAdmin, authorization is performed by ActiveAdminAdapter,
  # so skip it here.
  def skip_authorize_for_active_admin!
    skip_verify_authorized!
  end

  # Used by ActiveAdmin as an around_action to ensure datetime
  # fields are persisted in local TZ. Why an around_action instead of a
  # before_action? With a before_action, we cannot restore the value of
  # `Time.zone` for other tests after; the mutation of the system TZ
  # causes other tests to fail, e.g., related to embargo.
  def coerce_timezone_to_local
    Time.zone = 'America/Los_Angeles'
    yield
    Time.zone = Rails.application.config.time_zone
  end
end
