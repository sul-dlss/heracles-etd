# frozen_string_literal: true

module Elements
  # Renders a modal dialog
  class ModalComponent < ApplicationComponent
    renders_one :header # optional
    renders_one :footer # optional
    renders_one :body

    def initialize(id:, size: :lg, scrollable: false)
      @id = id
      @size = size
      @scrollable = scrollable # This was added to the component from H3
      super()
    end

    attr_reader :id

    def classes
      merge_classes('modal', @size ? "modal-#{@size}" : nil, @scrollable ? 'modal-dialog-scrollable' : nil)
    end
  end
end
