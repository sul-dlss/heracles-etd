# frozen_string_literal: true

module Admin
  # Policy for managing readers
  class ReaderPolicy < ApplicationPolicy
    alias_rule :new?, :create?, :index?, to: :manage?

    def manage?
      user.groups.dlss?
    end
  end
end
