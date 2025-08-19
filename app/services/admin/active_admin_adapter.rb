# frozen_string_literal: true

module Admin
  # Provides authorization for ActiveAdmin.
  # This allows members of the reports group to see reports without having access
  # to change submissions.
  class ActiveAdminAdapter < ActiveAdmin::AuthorizationAdapter
    include ActionPolicy::Behaviour

    def authorized?(action, subject = nil)
      return allowed_to?(:show?, with: AdminPolicy, context: { user: }) if subject.is_a?(ActiveAdmin::Page)

      clazz = subject.is_a?(Class) ? subject : subject.class
      policy = "Admin::#{clazz}Policy".safe_constantize

      # Dashboard is available to DLSS or Report user or Registrar.
      # Reader: all actions available to DLSS.
      # Report: read available to DLSS or Report user or Registrar. create available to DLSS.
      # Submission: read available to DLSS or Report user or Registrar.
      #   DLSS can edit once submitted. No one can create or delete.

      allowed_to?(:"#{action}?", subject, with: policy, context: { user: })
    end
  end
end
