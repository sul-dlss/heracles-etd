# frozen_string_literal: true

module Cocina
  # builds the Access subschema for Cocina DRO
  class DroAccessGenerator
    # @param [Submission] submission
    # @return [Hash] Cocina::Models::Access as a hash based on submission model for druid
    def self.create(submission:)
      new(submission:).props
    end

    def initialize(submission:)
      @submission = submission
    end

    def props
      {
        copyright: copyright_statement,
        license: license_url,
        embargo: embargo_props
      }.tap do |props|
        if world?
          props[:view] = 'world'
          props[:download] = 'world'
        else
          props[:view] = 'stanford'
          props[:download] = 'stanford'
          props[:embargo] = embargo_props if embargo_props
        end
      end.compact
    end

    private

    attr_reader :submission

    def world?
      releasable_date?(submission.embargo_release_date)
    end

    # submission.embargo can now be nil, which is equivalent to 'immediate' (= no embargo)
    #   this means release_date is also set to nil
    def releasable_date?(release_date)
      release_date.blank? || release_date.past?
    end

    def copyright_statement
      copyright_year = submission.submitted_at&.year&.to_s
      "(c) Copyright #{copyright_year} by #{submission.first_last_name}"
    end

    def license_url
      submission.creative_commons_license&.url
    end

    def embargo_props
      return unless submission.embargo_release_date&.future?

      { releaseDate: submission.embargo_release_date.iso8601, view: 'world', download: 'world' }.compact
    end
  end
end
