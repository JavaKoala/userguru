class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@user.guru'
  layout 'mailer'
end
