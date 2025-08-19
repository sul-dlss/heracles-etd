# frozen_string_literal: true

# Models the logged in user
class User
  USER_GROUPS_HEADER = 'eduPersonEntitlement'
  REMOTE_USER_HEADER = 'REMOTE_USER'
  ORCID_ID_HEADER =  'eduPersonOrcid'

  class << self
    def from_request(request:)
      new(
        remote_user: request.env[REMOTE_USER_HEADER],
        groups: groups_from_request(request:),
        orcid: orcid_from_request(request:)
      )
    end

    private

    # Returns the groups from shibboleth in production and the groups set in the
    # ROLES environment variable in development.
    def groups_from_request(request:)
      return request.env[USER_GROUPS_HEADER].split(';') if request.env[USER_GROUPS_HEADER]

      []
    end

    # Returns the ORCID from shibboleth in production and the ORCID set in the
    # ORCID environment variable in development.
    def orcid_from_request(request:)
      orcid = request.env[ORCID_ID_HEADER]
      return if orcid.nil? || orcid == '(null)'

      orcid
    end
  end

  def initialize(remote_user:, groups: [], orcid: nil)
    @sunetid = remote_user.split('@').first
    @groups = Groups.new(groups:)
    @orcid = orcid
  end

  attr_reader :sunetid, :groups, :orcid
end
