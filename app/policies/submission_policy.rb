# frozen_string_literal: true

# Policy for managing submissions
class SubmissionPolicy < ApplicationPolicy
  alias_rule :edit?, :show?, :update?, to: :manage?

  def manage?
    record.sunetid == user.sunetid
  end

  def reader_review?
    record.readers.exists?(sunetid: user.sunetid)
  end
end
