# frozen_string_literal: true

module Registrar
  # Parse and normalize submission input (XML) from project partners
  class SubmissionInputParser
    def self.parse(...)
      new(...).parse
    end

    def initialize(**params)
      @params = params.fetch(:DISSERTATION)
    end

    def parse # rubocop:disable Metrics/AbcSize
      SubmissionInput.new(@params).to_h.tap do |hash|
        # Normalize the hash into a shape that matches the ETD app's domain language
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
  end
end
