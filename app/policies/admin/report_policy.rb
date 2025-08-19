# frozen_string_literal: true

module Admin
  # Policy for managing reports
  class ReportPolicy < ApplicationPolicy
    alias_rule :new?, :create?, to: :manage?

    def read?
      user.groups.dlss? || user.groups.reports? || user.groups.registrar?
    end

    def manage?
      user.groups.dlss?
    end
  end
end
