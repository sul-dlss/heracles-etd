# frozen_string_literal: true

# Concern for handling person names.
module PersonNameConcern
  extend ActiveSupport::Concern

  def first_name
    name.split(', ').last
  end

  def first_last_name
    name.split(', ').reverse.join(' ').tap do |full_name|
      full_name << ", #{suffix}" if suffix.present?
    end
  end
end
