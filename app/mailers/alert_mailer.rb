# frozen_string_literal: true

# Mailer for sending alerts related to ETD submissions
class AlertMailer < ApplicationMailer
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
