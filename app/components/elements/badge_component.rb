# frozen_string_literal: true

module Elements
  # Component for displaying a badge
  class BadgeComponent < ApplicationComponent
    def initialize(value:, variant: :primary, classes: '')
      @value = value
      @variant = variant
      @classes = classes
      super()
    end

    attr_reader :value, :variant

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
