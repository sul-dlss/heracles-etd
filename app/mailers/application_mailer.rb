# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "Etd App <#{Settings.etd_alerts_list}>",
          to: Settings.etd_cataloging_list
  layout 'mailer'
end
