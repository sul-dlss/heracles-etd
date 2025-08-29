# frozen_string_literal: true

#
# Policy for managing ETDs
class EtdPolicy < ApplicationPolicy
  # Only allow creating ETDs via the API with HTTP basic authentication.
  alias_rule :index?, :create?, to: :authenticated?

  def authenticated?
    http_basic_authenticate_or_request_with(
      name: Settings.dlss_admin,
      password: Settings.dlss_admin_pw,
      realm: 'Application',
      message: 'You are unauthorized to perform this action'
    )
  end
end
