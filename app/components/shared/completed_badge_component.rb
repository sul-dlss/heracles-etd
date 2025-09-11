# frozen_string_literal: true

module Shared
  # Component for displaying a "completed" badge
  class CompletedBadgeComponent < ApplicationComponent
    def initialize(**args)
      @args = args
      super()
    end

    def call
      render Elements::BadgeComponent.new(value: 'Completed', variant: 'completed', **@args)
    end
  end
end
