# frozen_string_literal: true

module Edit
  # Component for editing step 3 of the submitter form
  class Step4Component < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
