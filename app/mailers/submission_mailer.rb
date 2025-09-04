# frozen_string_literal: true

# Mailer for sending cataloging report emails for new submissions
class SubmissionMailer < ApplicationMailer
  def ready_for_cataloging
    return unless mailable_environment?

    Honeybadger.check_in(Settings.honeybadger_checkins.ready_for_cataloging)

    # ETDs loaded since yesterday morning
    @etds_uncataloged_new = Submission.ils_records_created_since_yesterday_morning.order(:folio_instance_hrid)
    # All ETDs awaiting full cataloging
    @etds_uncataloged_all = Submission.at_ils_loaded.where.not(druid: Settings.skip_cataloging_alert)
                                      .order(:folio_instance_hrid)

    return if @etds_uncataloged_all.empty?

    mail(subject: "[#{environment.upcase}] ETDs ready to be cataloged",
         template_name: 'ready_for_cataloging')
  end

  private

  def environment
    Honeybadger.config[:env]
  end

  def mailable_environment?
    environment.in?(Settings.mailable_environments)
  end
end
