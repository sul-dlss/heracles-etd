# frozen_string_literal: true

module Admin
  # Adapts ActiveAdmin authorization to ActionPolicy authorization.
  #
  # Dashboard is available to DLSS or Report user or Registrar.
  #
  # Reader: all actions available to DLSS.
  # Report: read available to DLSS or Report user. create available to DLSS.
  # Submission: index available to DLSS or Report user, show available to DLSS. DLSS can edit once
  #             submitted. No one can create or delete.
  class ActionPolicyAdapter < ActiveAdmin::AuthorizationAdapter
    def authorized?(action, subject = nil)
      target = policy_target(subject)
      policy = ActionPolicy.lookup(target, namespace: Admin, default: AdminPolicy)
      action = format_action(action, subject)
      policy.new(target, user:).apply(action)
    end

    private

    def format_action(action, subject)
      case action
      when ActiveAdmin::Auth::CREATE
        :create?
      when ActiveAdmin::Auth::UPDATE
        :update?
      when ActiveAdmin::Auth::READ
        subject.is_a?(Class) ? :index? : :show?
      when ActiveAdmin::Auth::DESTROY
        subject.is_a?(Class) ? :destroy_all? : :destroy?
      else
        :"#{action}?"
      end
    end

    def policy_target(subject)
      case subject
      when nil
        resource.resource_class
      when Class
        subject.new
      else
        subject
      end
    end
  end
end
