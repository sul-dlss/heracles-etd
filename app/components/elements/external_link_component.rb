# frozen_string_literal: true

module Elements
  # Component for displaying an external link with an icon
  class ExternalLinkComponent < ApplicationComponent
    def initialize(url:, label: nil, classes: [])
      @url = url
      @label = label # Provide label or content, otherwise the url is used.
      @classes = classes
      super()
    end

    attr_reader :url, :label

    def classes
      merge_classes(@classes)
    end
  end
end
