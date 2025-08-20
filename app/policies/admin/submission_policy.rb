# frozen_string_literal: true

module Admin
  # Policy for managing submissions
  class SubmissionPolicy < ApplicationPolicy
    def read?
      user.groups.dlss? || user.groups.registrar? || user.groups.reports?
    end

    def destroy?
      false
    end

    def new?
      false
    end

    def manage?
      # allow group dlss to edit Submissions after student has submitted them
      record.submitted_at.present? && user.groups.dlss?
    end
  end
end
