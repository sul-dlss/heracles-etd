# frozen_string_literal: true

module Elements
  # Renders a modal dialog
  # This component has been modified from H3.
  class ModalComponent < ApplicationComponent
    renders_one :footer # optional
    renders_one :body

    def initialize(id:, title:, size: :lg, scrollable: false)
      @id = id
      @size = size
      @scrollable = scrollable
      @title = title
      super()
    end

    attr_reader :id, :title

    def classes
      merge_classes('modal', @size ? "modal-#{@size}" : nil, @scrollable ? 'modal-dialog-scrollable' : nil)
    end

    def title_id
      "#{id}-title"
    end
  end
end
