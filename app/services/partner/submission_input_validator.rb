# frozen_string_literal: true

module Partner
  # Validate submission input (XML) from project partners
  class SubmissionInputValidator
    PHD_REGEX = /p\W*h\W*d/i
    ENG_REGEX = /^eng$/i

    def initialize(**params)
      @params = params
    end

    def parse!
      @result = Contract.new.call(params)
    end

    def valid?
      result.errors.blank?
    end

    def error_message
      result.errors(full: true).messages.join('; ')
    end

    def parsed # rubocop:disable Metrics/AbcSize
      @parsed ||= result.to_h.fetch(:DISSERTATION).tap do |hash|
        hash[:dissertation_id] = hash.delete(:dissertationid)
        hash[:etd_type] = hash.delete(:type)
        hash[:provost] = hash.delete(:vpname)
        hash[:ps_career] = hash.delete(:career)
        hash[:department] = hash.delete(:program)
        hash[:major] = hash.delete(:plan)
        hash[:ps_subplan] = hash.delete(:subplan) if hash.key?(:subplan)
        hash[:readers] = hash.delete(:reader)
        if (deadline = hash.dig(:sub, :deadline)).present?
          hash[:sub] = deadline
        end
      end
    end

    private

    attr_reader :params, :result

    # Define custom types in the contract to handle value normalization
    module Types
      include Dry.Types()

      DocumentAccess = Types::String.enum('Yes', 'No')
      FinalReader = Types::String.enum('Yes', 'No', 'N')
      NameWithSpacesAfterCommas = Types::String.constructor { |name| name.gsub(/,(\S)/, ', \1') }
      NormalizedDegree = Types::String.constructor do |degree|
        if PHD_REGEX.match?(degree)
          'Ph.D.'
        elsif ENG_REGEX.match?(degree)
          'Engineering'
        else
          degree
        end
      end
      ReaderRole = Types::String.enum(*(Reader::ADVISOR_ROLES + Reader::NON_ADVISOR_ROLES))
      ReaderType = Types::String.enum('ext', 'int')
      SquishedTitle = Types::String.constructor(&:squish)
      SubmissionType = Types::String.enum('Dissertation', 'Thesis')
      SubDeadline = Types::String.constructor { |sub| "deadline #{sub}" }
    end

    # This is the contract we have with the Registrar governing what form their input data will take.
    class Contract < Dry::Validation::Contract
      schema do # rubocop:disable Metrics/BlockLength
        required(:DISSERTATION).hash do # rubocop:disable Metrics/BlockLength
          required(:dissertationid).filled(:string)
          required(:title).filled(Types::SquishedTitle)
          required(:type).filled(Types::SubmissionType)
          required(:vpname).filled(:string)
          required(:degreeconfyr).filled(:string)
          required(:schoolname).filled(:string)
          required(:documentaccess).filled(Types::DocumentAccess)
          required(:univid).filled(:string)
          required(:sunetid).filled(:string)
          required(:name).filled(Types::NameWithSpacesAfterCommas)
          required(:career).filled(:string)
          required(:program).filled(:string)
          required(:plan).filled(:string)
          required(:degree).filled(Types::NormalizedDegree)
          required(:sub).hash do
            required(:deadline).maybe(Types::SubDeadline)
          end

          optional(:external_visibility).maybe(:string)
          optional(:prefix).maybe(:string)
          optional(:suffix).maybe(:string)
          optional(:term).maybe(:string)
          optional(:subplan).maybe(:string)

          required(:reader).array(:hash) do
            required(:type).filled(Types::ReaderType)
            required(:univid).maybe(:string)
            required(:sunetid).maybe(:string)
            required(:name).filled(:string)
            required(:readerrole).maybe(:string) # .filled(Types::ReaderRole)
            required(:finalreader).filled(Types::FinalReader)
            optional(:prefix).maybe(:string)
            optional(:suffix).maybe(:string)
          end

          required(:readerapproval).maybe(:string)
          required(:readercomment).maybe(:string)
          required(:readeractiondttm).maybe(:string)
          required(:regapproval).maybe(:string)
          required(:regcomment).maybe(:string)
          required(:regactiondttm).maybe(:string)
        end
      end

      rule(DISSERTATION: :reader).each do
        next if value[:type] == 'ext'

        key.failure("Internal reader does not have a univ. id: #{value[:name]}") if value[:univid].blank?
        key.failure("Internal reader does not have a SUNet ID: #{value[:name]}") if value[:sunetid].blank?
      end
    end
  end
end
