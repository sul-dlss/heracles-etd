# frozen_string_literal: true

# Policy for managing submissions
class SubmissionPolicy < ApplicationPolicy
  alias_rule :preview?, to: :show?
  alias_rule :edit?, :submit?, :review?, to: :update?

  def show?
    author? || admin?
  end

  # No one can edit when the submission has already been submitted.
  #
  # Before being submitted, only the student (author) can edit it, unless we're
  # in the UAT environment in which case the registrar group can also edit it.
  def update?
    return false if record.submitted?

    author? || registrar_can_act_as_student?
  end

  def reader_review?
    record.readers.exists?(sunetid: user.sunetid) || admin?
  end

  private

  def author?
    record.sunetid == user.sunetid
  end

  def admin?
    user.groups.dlss? || user.groups.registrar?
  end

  def registrar_can_act_as_student?
    user.groups.registrar? && Honeybadger.config[:env] == 'uat'
  end
end
