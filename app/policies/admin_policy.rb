# frozen_string_literal: true

# Policy for admin actions
class AdminPolicy < ApplicationPolicy
  # dashboard
  def show?
    user.groups.dlss? || user.groups.reports?
  end
end
