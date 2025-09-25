# frozen_string_literal: true

module Shared
  # Component for rendering the body of the rights step.
  class RightsStepBodyComponent < ApplicationComponent
    def initialize(submission:)
      @submission = submission
      super()
    end

    attr_reader :submission

    delegate :copyright_statement, :embargo_release_date, :etd_type, :last_registrar_action_at, :regapproval,
             :embargo, to: :submission

    def external_release_date_message # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
      if last_registrar_action_at && /approved/i.match?(regapproval)
        if embargo.present? && embargo != 'immediately'
          "This #{etd_type_label} will be publicly available on <strong>#{formatted_release_date}" \
            "</strong> (includes #{delay_duration_label} delay requested by the author)."
        else
          "This #{etd_type_label} will be publicly available on <strong>#{formatted_release_date}</strong>."
        end
      elsif embargo.present? && embargo != 'immediately'
        "The author has requested that this #{etd_type_label} be made publicly available <strong>" \
          "#{embargo}</strong> after final approval by the Registrar."
      else
        "This #{etd_type_label} will be publicly available after final approval by " \
          "the Registrar's Office and processing by the Stanford University Libraries."
      end
        .html_safe # rubocop:disable Rails/OutputSafety
    end

    def license
      submission.creative_commons_license
    end

    private

    def formatted_release_date
      helpers.l(embargo_release_date.to_date, format: :long)
    end

    def etd_type_label
      etd_type.downcase
    end

    def delay_duration_label
      embargo.chomp('s').parameterize
    end
  end
end
