# frozen_string_literal: true

# Policy for admin actions
class AdminPolicy < ApplicationPolicy
  def test_submission?
    user.groups.dlss?
  end
end
