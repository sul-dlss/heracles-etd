# frozen_string_literal: true

module Edit
  # Component for displaying an "in progress" badge
  class InProgressBadgeComponent < ApplicationComponent
    def initialize(**args)
      @args = args
      super()
    end

    def call
      render Elements::BadgeComponent.new(value: 'In Progress', variant: 'in-progress', **@args)
    end
  end
end
