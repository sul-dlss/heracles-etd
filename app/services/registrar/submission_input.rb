# frozen_string_literal: true

module Registrar
  # This is the contract we have with the Registrar governing what form their input data will take.
  class SubmissionInput < Dry::Struct
    PHD_REGEX = /p\W*h\W*d/i
    ENG_REGEX = /^eng$/i

    transform_keys(&:to_sym)

    attribute(:dissertationid, Types::NonEmptyString)
    attribute(:title, Types::NonEmptyString.constructor(&:squish))
    attribute(:type, Types::NonEmptyString.enum('Dissertation', 'Thesis'))
    attribute(:vpname, Types::NonEmptyString)
    attribute(:degreeconfyr, Types::NonEmptyString)
    attribute(:schoolname, Types::NonEmptyString)
    attribute(:documentaccess, Types::NonEmptyString.enum('Yes', 'No'))
    attribute(:univid, Types::NonEmptyString)
    attribute(:sunetid, Types::NonEmptyString)
    attribute(:name, Types::NonEmptyString.constructor { |name| name.gsub(/,(\S)/, ', \1') })
    attribute(:career, Types::NonEmptyString)
    attribute(:program, Types::NonEmptyString)
    attribute(:plan, Types::NonEmptyString)
    attribute(:degree, Types::NonEmptyString.constructor do |degree|
      if PHD_REGEX.match?(degree)
        'Ph.D.'
      elsif ENG_REGEX.match?(degree)
        'Engineering'
      else
        degree
      end
    end)
    attribute :sub do
      attribute(:deadline, Types::Strict::String.optional.constructor { |sub| "deadline #{sub}" })
    end

    attribute?(:prefix, Types::Strict::String.optional)
    attribute?(:suffix, Types::Strict::String.optional)
    attribute?(:subplan, Types::Strict::String.optional)

    attribute(:reader, ReaderInput | Types::Array.of(ReaderInput))
    attribute(:readerapproval, Types::Strict::String.optional)
    attribute(:readercomment, Types::Strict::String.optional)
    attribute(:readeractiondttm, Types::Strict::String.optional)
    attribute(:regapproval, Types::Strict::String.optional)
    attribute(:regcomment, Types::Strict::String.optional)
    attribute(:regactiondttm, Types::Strict::String.optional)
  end
end
