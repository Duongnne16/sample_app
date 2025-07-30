class ApplicationMailer < ActionMailer::Base
  default from: Settings.defaults.default_email
  layout "mailer"
end
