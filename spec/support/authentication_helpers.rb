# frozen_string_literal: true

# Helpers to assist with authentication.
module AuthenticationHelpers
  def sign_in(login = nil, groups: [])
    TestShibbolethHeaders.user = login
    TestShibbolethHeaders.groups = groups
    TestShibbolethHeaders.orcid = Settings.test_orcid
  end

  def sign_out
    TestShibbolethHeaders.user = nil
    TestShibbolethHeaders.groups = nil
    TestShibbolethHeaders.orcid = nil
  end

  RSpec.configure do |config|
    config.include AuthenticationHelpers, type: :system
    config.include AuthenticationHelpers, type: :request
  end
end
