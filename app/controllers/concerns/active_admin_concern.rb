# frozen_string_literal: true

# Concern containing all ActiveAdmin-related functionality
module ActiveAdminConcern
  extend ActiveSupport::Concern
  include ActionPolicy::Behaviour

  # ActionPolicy requires authorization. For ActiveAdmin, authorization is performed by ActionPolicyAdapter,
  # so skip it here.
  def skip_authorize_for_active_admin!
    skip_verify_authorized!
  end
end
