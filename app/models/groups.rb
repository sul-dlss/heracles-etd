# frozen_string_literal: true

# The permissions groups the user is part of
class Groups
  def initialize(groups:)
    @groups = groups
  end

  def dlss?
    @groups.include?(Settings.groups.dlss)
  end

  def registrar?
    @groups.include?(Settings.groups.registrar)
  end

  def reports?
    @groups.include?(Settings.groups.reports)
  end

  def to_s
    @groups.join(', ')
  end
end
