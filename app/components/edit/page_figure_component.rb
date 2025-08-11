# frozen_string_literal: true

module Edit
  # Component for displaying a figure of a submission page
  class PageFigureComponent < ApplicationComponent
    def initialize(title:, with_x: false, footer: nil)
      @title = title
      @with_x = with_x
      @footer = footer
      super()
    end

    attr_reader :title, :footer

    def with_x?
      @with_x
    end
  end
end
