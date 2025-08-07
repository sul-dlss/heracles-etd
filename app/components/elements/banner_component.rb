# frozen_string_literal: true

module Elements
  # Banner component for displaying messages, welcomes, etc.
  class BannerComponent < ApplicationComponent
    renders_one :header
    renders_one :body

    ICONS = {
      note: 'bi bi-exclamation-circle-fill',
      success: 'bi bi-check-circle-fill',
      warning: 'bi bi-exclamation-triangle-fill',
      info: 'bi bi-info-circle-fill',
      danger: 'bi bi-exclamation-triangle-fill'
    }.freeze

    def initialize(title: nil, variant: :note, classes: [])
      @title = title
      @variant = variant.to_sym
      @classes = classes
      raise ArgumentError, "Unknown variant: #{variant}" unless ICONS.key?(variant)

      super()
    end

    attr_reader :title, :variant

    def icon_classes
      merge_classes('fs-3 me-3 align-self-center d-flex justify-content-center', ICONS[variant])
    end

    def classes
      merge_classes('alert banner d-flex shadow-sm align-items-center p-3 mb-3 border-start', "alert-#{variant}",
                    @classes)
    end
  end
end
