# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "Etd App <#{Settings.etd_alerts_list}>",
          to: Settings.etd_alerts_list
  layout 'mailer'
end
