# frozen_string_literal: true

module Edit
  # Component for editing step 2 of the submitter form
  class Step2Component < ApplicationComponent
    def initialize(form:)
      @form = form
      super()
    end

    attr_reader :form
  end
end
