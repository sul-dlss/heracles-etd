# frozen_string_literal: true

module Elements
  # An alert component for displaying status messages.
  # This should be used when the information is not important or time-sensitive.
  class StatusAlertComponent < Elements::AlertComponent
    def initialize(**args)
      args[:role] = nil
      super
    end
  end
end
