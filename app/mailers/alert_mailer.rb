# frozen_string_literal: true

# Mailer for sending alerts related to ETD submissions
class AlertMailer < ApplicationMailer
  def ps_submit_exception(dissertation_id, exception_msg)
    @id = dissertation_id
    @msg = exception_msg
    send_message(subject: "#{subject_prefix} Error submitting ETD information to PeopleSoft",
                 template_name: 'ps_submit_exception')
  end

  def ps_incoming_dissertation_exception(dissertation_id, exception_msg)
    @id = dissertation_id
    @msg = exception_msg
    send_message(subject: "#{subject_prefix} Error processing incoming dissertation from Peoplesoft",
                 template_name: 'ps_incoming_dissertation_exception')
  end

  def corrupt_pdf_notification(dissertation_id, exception_msg)
    @id = dissertation_id
    @msg = exception_msg
    send_message(subject: "#{subject_prefix} Error creating augmented pdf",
                 template_name: 'corrupt_pdf_notification')
  end

  def readers_missing(dissertation_id)
    @id = dissertation_id
    send_message(subject: "#{subject_prefix} Dissertation is missing readers",
                 template_name: 'readers_missing')
  end

  def unable_to_create_workflow(dissertation_id)
    send_workflow_message('create', dissertation_id)
  end

  def unable_to_update_workflow(dissertation_id)
    send_workflow_message('update', dissertation_id)
  end

  def send_workflow_message(action, dissertation_id)
    @id = dissertation_id
    @action = action
    send_message(subject: "#{subject_prefix} Error with Etd Submit workflow #{action}",
                 template_name: 'workflow_problem')
  end

  def unable_to_build_marc(filename, detail, exception)
    @filename = filename
    @detail = detail
    @exception = exception
    send_message(subject: "#{subject_prefix} Failed to build MARC record",
                 template_name: 'marc_problem')
  end

  def ready_for_cataloging
    # ETDs loaded since yesterday morning
    @etds_uncataloged_new = Submission.ils_records_created_since_yesterday_morning.order(:folio_instance_hrid)
    # All ETDs awaiting full cataloging
    @etds_uncataloged_all = Submission.at_ils_loaded.where.not(druid: Settings.skip_cataloging_alert)
                                      .order(:folio_instance_hrid)

    return if @etds_uncataloged_all.empty?

    send_message(subject: "#{subject_prefix} ETDs ready to be cataloged",
                 template_name: 'ready_for_cataloging',
                 to_address: Settings.etd_cataloging_list)
  end

  private

  def subject_prefix
    "[#{Settings.ps_env.upcase}]"
  end

  def send_message(subject:, template_name:, to_address: nil)
    return unless alertable_environment?

    to_address ||= self.class.default[:to]
    mail(subject:, template_name:, to: to_address)
  end

  def alertable_environment?
    Settings.ps_env.in?(Settings.alertable_environments)
  end
end
