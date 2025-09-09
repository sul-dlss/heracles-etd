# frozen_string_literal: true

module Edit
  # Component for displaying a single character in a circle
  class CharacterCircleComponent < ApplicationComponent
    def initialize(id: nil, character: '', classes: ['me-2 my-2'], variant: :disabled)
      @character = character.to_s
      @classes = classes
      @variant = variant
      @id = id

      raise ArgumentError unless %i[disabled success blank].include?(variant.to_sym)

      raise ArgumentError, 'Character must be a single character' if @character.length > 1

      super()
    end

    def call
      tag.div(
        class: classes,
        id: @id
      ) do
        character.to_s
      end
    end

    def classes
      merge_classes('character-circle', "character-circle-#{@variant}", @classes)
    end

    def character
      return '&nbsp;'.html_safe if @character == ''

      @character.to_s
    end
  end
end
