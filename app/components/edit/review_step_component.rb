# frozen_string_literal: true

module Edit
  # Component for displaying a collapsible step on the submitter form that requires user review.
  class ReviewStepComponent < ApplicationComponent
    renders_one :help_content
    renders_one :body_content

    def initialize(form:, review_field:, show: true, data: {}, done_data: {}, edit_data: {}, **args)
      @form = form
      @review_field = review_field
      @data = data
      @done_data = done_data
      @edit_data = edit_data
      @show = show
      @args = args

      super()
    end

    attr_reader :args, :review_field, :form, :show

    def data
      @data.merge(controller: merge_actions(@data[:controller], 'confirm'))
    end

    def done_data
      @done_data.merge(action: merge_actions(@done_data[:action], 'confirm#confirm'))
    end

    def edit_data
      action = show ? 'confirm#confirm submit-form#toggleAndSubmit' : 'confirm#unconfirm submit-form#toggleAndSubmit'
      @edit_data.merge(action: merge_actions(@edit_data[:action], action))
    end
  end
end
