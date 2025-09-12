# frozen_string_literal: true

module Elements
  module Forms
    # Component for a toggle-like radio button group field
    class ToggleComponent < ApplicationComponent
      renders_one :left_toggle_option, ->(**args) {
        Elements::Forms::ToggleOptionComponent.new(position: :left, **args)
      }
      renders_one :right_toggle_option, ->(**args) {
        Elements::Forms::ToggleOptionComponent.new(position: :right, **args)
      }

      def initialize(form:, field_name:, container_classes:, data: {})
        @form = form
        @field_name = field_name
        @container_classes = container_classes
        @data = data
        super()
      end

      attr_reader :form, :field_name, :container_classes, :data
    end
  end
end
