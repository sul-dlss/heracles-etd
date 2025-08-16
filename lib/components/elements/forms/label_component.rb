# frozen_string_literal: true

module Elements
  module Forms
    # Component for rendering a form label.
    class LabelComponent < ApplicationComponent
      def initialize(form:, field_name:, label_text: nil, default_label_class: 'form-label', hidden_label: false, # rubocop:disable Metrics/ParameterLists
                     classes: [], caption: nil)
        @form = form
        @label_text = label_text
        @field_name = field_name
        @hidden_label = hidden_label
        @default_label_class = default_label_class
        @classes = classes
        @caption = caption
        super()
      end

      attr_reader :field_name, :form, :caption

      def label_text
        return field_name if @label_text.blank?

        @label_text
      end

      def classes
        merge_classes(@default_label_class, @classes, @hidden_label ? 'visually-hidden' : nil)
      end
    end
  end
end
