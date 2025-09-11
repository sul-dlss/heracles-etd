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
end
