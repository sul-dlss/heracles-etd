# frozen_string_literal: true

# Models the logged in user
class User
  EMAIL_SUFFIX = '@stanford.edu'

  def initialize(remote_user:, groups: [], orcid: nil)
    @remote_user = remote_user
    @sunetid = remote_user.split('@').first
    @groups = Groups.new(groups:)
    @orcid = orcid
  end

  attr_reader :sunetid, :groups, :orcid
end
