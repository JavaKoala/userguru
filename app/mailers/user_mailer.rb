class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation", from: setting_value("default_email")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def new_user_activated(new_user, admin_user)
    @new_user = new_user
    mail to: admin_user.email, subject: "New user activated", from: setting_value("default_email")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
   @user = user
   mail to: user.email, subject: "Password reset", from: setting_value("default_email")
  end
end
