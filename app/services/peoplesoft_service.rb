# frozen_string_literal: true

# Service for applying registrar based actions from Peoplesoft
class PeoplesoftService
  def self.update(...)
    new(...).update
  end

  def initialize(submission:, submission_params:)
    @submission = submission
    @submission_params = submission_params
  end

  def update # rubocop:disable Metrics/AbcSize
    submission.transaction do
      # First, assign the readers anew
      submission.readers.destroy_all
      submission.readers.create!(readers)

      update_reader_actions!
      update_registrar_actions!

      # Handle when submission is rejected and when is has been fully approved
      if /reject/i.match?(submission.readerapproval) || /reject/i.match?(submission.regapproval)
        submission.update!(submitted_at: nil, submitted_to_registrar: 'false')
      elsif submission.ready_for_cataloging?
        CreateStubMarcRecordJob.perform_later(submission.druid)
        CreateEmbargo.call(submission.druid, submission.embargo_release_date)
      end
    end
  end

  private

  attr_reader :submission, :submission_params

  def readers
    @readers ||= Reader.sorted_list(submission_params[:reader])
  end

  def update_reader_actions!
    return unless valid_action?(
      new_action: reader_action_datetime,
      previous_action: submission.last_reader_action_at
    )

    submission.update!(
      readerapproval: submission_params[:readerapproval],
      readercomment: submission_params[:readercomment],
      last_reader_action_at: reader_action_datetime
    )
  end

  def update_registrar_actions!
    return unless valid_action?(
      new_action: registrar_action_datetime,
      previous_action: submission.last_registrar_action_at
    )

    submission.update!(
      regapproval: submission_params[:regapproval],
      regcomment: submission_params[:regcomment],
      last_registrar_action_at: registrar_action_datetime
    )
  end

  def valid_action?(new_action:, previous_action:)
    return false unless submission.submitted?
    return false unless new_action
    return false if previous_action && (previous_action - new_action).abs < 1.0

    new_action > submission.submitted_at
  end

  def registrar_action_datetime
    @registrar_action_datetime ||= parse_datetime(submission_params[:regactiondttm])
  end

  def reader_action_datetime
    @reader_action_datetime ||= parse_datetime(submission_params[:readeractiondttm])
  end

  def parse_datetime(date_string)
    return if date_string.blank?

    DateTime.strptime(date_string, '%m/%d/%Y %T').in_time_zone(Rails.application.config.time_zone)
  end
end
