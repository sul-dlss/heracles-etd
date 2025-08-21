# frozen_string_literal: true

TEST_ORCID = '0000-0002-2100-6108'

# Helpers to assist with authentication.
module AuthenticationHelpers
  def sign_in(login = nil, groups: [], orcid: TEST_ORCID)
    TestShibbolethHeaders.user = login
    TestShibbolethHeaders.groups = groups
    TestShibbolethHeaders.orcid = orcid
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
