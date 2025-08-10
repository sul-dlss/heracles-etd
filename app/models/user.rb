# frozen_string_literal: true

# Models the logged in user
class User < ApplicationRecord
  EMAIL_SUFFIX = '@stanford.edu'

  def sunetid
    email_address.delete_suffix(EMAIL_SUFFIX)
  end
end
