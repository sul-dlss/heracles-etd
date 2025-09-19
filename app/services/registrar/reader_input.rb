# frozen_string_literal: true

module Registrar
  # This is a subschema for readers.
  class ReaderInput < Dry::Struct
    transform_keys(&:to_sym)

    attribute(:type, Types::NonEmptyString.enum('ext', 'int'))
    attribute(:univid, Types::Strict::String.optional)
    attribute(:sunetid, Types::Strict::String.optional)
    attribute(:name, Types::NonEmptyString)
    attribute(:readerrole, Types::NonEmptyString.enum(*(::Reader::ADVISOR_ROLES + ::Reader::NON_ADVISOR_ROLES)))
    attribute(:finalreader, Types::NonEmptyString.enum('Yes', 'No', 'N'))
    attribute?(:prefix, Types::Strict::String.optional)
    attribute?(:suffix, Types::Strict::String.optional)
  end
end
