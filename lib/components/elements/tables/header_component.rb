# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table header.
    class HeaderComponent < ApplicationComponent
      def initialize(label:, classes: [], style: nil)
        @label = label
        @classes = classes
        @style = style
        super()
      end

      attr_reader :label, :style

      def classes
        merge_classes(@classes)
      end
    end
  end
end
