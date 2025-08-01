class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def password_resets user
    @user = user
    mail to: user.email, subject: "Password reset"
  end

  def password_changed user
    @user = user
    @login_url = login_url(locale: I18n.locale)
    mail to: user.email, subject: t("user_mailer.password_changed.subject")
  end
end
