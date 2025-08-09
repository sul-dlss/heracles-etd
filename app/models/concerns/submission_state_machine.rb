# frozen_string_literal: true

# Defines the submission and review states for an ETD submission
module SubmissionStateMachine
  extend ActiveSupport::Concern

  included do
    # This represents the submission state during review and processing
    # This does not represent the version status in SDR.
    state_machine :submission_state, initial: :registered do
      event :submitted do
        transition registered: :submitted
      end

      event :reader_approved do
        transition submitted: :reader_approved
      end

      event :registrar_approved do
        transition reader_approved: :registrar_approved
      end

      event :registered_with_catalog do
        transition registrar_approved: :registered_with_catalog
      end

      event :cataloged do
        transition registered_with_catalog: :cataloged
      end

      event :accessioning do
        transition cataloged: :accessioning
      end

      before_transition submitted: :reader_approved do |submission|
        submission.update!(last_reader_action_at: Time.zone.now)
      end

      before_transition reader_approved: :registrar_approved do |submission|
        submission.update!(last_registrar_action_at: Time.zone.now)
      end

      before_transition registered_with_catalog: :registrar_approved do |submission|
        submission.update!(ils_record_created_at: Time.zone.now)
      end

      before_transition cataloged: :registered_with_catalog do |submission|
        submission.update!(ils_record_updated_at: Time.zone.now)
      end

      before_transition accessioning: :cataloged do |submission|
        submission.update!(accessioning_started_at: Time.zone.now)
      end
      # TBD: Do we need a state for "accessioned"?
    end
  end
end
