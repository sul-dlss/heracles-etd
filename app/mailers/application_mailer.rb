# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "Etd App <#{Settings.etd_mail_from}>",
          to: Settings.etd_cataloging_list
  layout 'mailer'
end
