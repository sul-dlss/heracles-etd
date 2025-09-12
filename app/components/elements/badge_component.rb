# frozen_string_literal: true

module Elements
  # Component for displaying a badge
  class BadgeComponent < ApplicationComponent
    def initialize(value:, variant: :primary, classes: %w[ms-3 mt-1], id: nil)
      @value = value
      @variant = variant
      @classes = classes
      @id = id
      super()
    end

    attr_reader :value, :variant, :id

    def classes
      merge_classes('badge', "badge-#{@variant}", @classes)
    end

    def call
      tag.div(class: classes) do
        @value
      end
    end
  end
end
