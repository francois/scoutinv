class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.send_authentication.subject
  #
  def send_authentication(email, session_url)
    @session_url = session_url
    mail to: email
  end
end
