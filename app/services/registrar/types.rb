# frozen_string_literal: true

module Registrar
  # Define custom types to handle value normalization
  module Types
    include Dry.Types()

    NonEmptyString = Strict::String.constrained(format: /\S/)
  end
end
