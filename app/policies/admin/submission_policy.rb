# frozen_string_literal: true

module Admin
  # Policy for managing submissions
  class SubmissionPolicy < ApplicationPolicy
    alias_rule :new?, to: :create?

    def index?
      user.groups.dlss? || user.groups.reports?
    end

    def show?
      user.groups.dlss?
    end

    def destroy?
      false
    end

    def create?
      user.groups.dlss?
    end

    def manage?
      # allow group dlss to edit Submissions, but...
      return false unless user.groups.dlss?

      # ...only if it's the local dev environment, *OR* after the submission has been submitted
      Rails.env.development? || record.submitted_at.present?
    end
  end
end
