class ApplicationMailer < ActionMailer::Base

  include SettingsHelper

  default from: 'no-reply@user.guru'
  layout 'mailer'
end
