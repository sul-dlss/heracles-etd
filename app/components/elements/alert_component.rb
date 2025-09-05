# frozen_string_literal: true

module Elements
  # Component for rendering an alert.
  class AlertComponent < ApplicationComponent
    # NOTE: This component has been altered from the H3 version.

    ICONS = {
      danger: 'bi bi-exclamation-triangle-fill',
      success: 'bi bi-check-circle-fill',
      note: 'bi bi-exclamation-circle-fill',
      info: 'bi bi-info-circle-fill',
      warning: 'bi bi-exclamation-triangle-fill'
    }.freeze

    # Variants are :danger, :success, :note, :info, :warning, :input
    # input is not part of the component library
    def initialize(title: nil, variant: :info, dismissible: false, value: nil, data: {}, classes: [], id: nil,
                   role: 'alert')
      raise ArgumentError, 'Invalid variant' unless %i[danger success note info warning input].include?(variant.to_sym)

      @title = title
      @variant = variant.to_sym
      @dismissible = dismissible
      @value = value
      @data = data
      @classes = classes
      @id = id
      @role = role
      super()
    end

    attr_reader :title, :variant, :value, :data, :id, :role

    def classes
      merge_classes(%w[alert d-flex shadow-sm align-items-center], variant_class, dismissible_class, @classes)
    end

    def variant_class
      "alert-#{variant}"
    end

    def dismissible_class
      'alert-dismissible' if dismissible?
    end

    def dismissible?
      @dismissible
    end

    def icon?
      ICONS.key?(variant)
    end

    def icon_classes
      merge_classes('fs-3 me-3 align-self-center d-flex justify-content-center', ICONS[variant])
    end

    def render?
      title.present? || value.present? || content.present?
    end
  end
end
