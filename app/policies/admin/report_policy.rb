# frozen_string_literal: true

module Admin
  # Policy for managing reports
  class ReportPolicy < ApplicationPolicy
    alias_rule :new?, :create?, to: :manage?
    alias_rule :index?, to: :show?

    def show?
      user.groups.dlss? || user.groups.reports?
    end

    def manage?
      user.groups.dlss?
    end
  end
end
