# frozen_string_literal: true

module Admin
  # Policy for managing readers
  class ReaderPolicy < ApplicationPolicy
    # manage? is the default rule.
    def manage?
      user.groups.dlss?
    end
  end
end
