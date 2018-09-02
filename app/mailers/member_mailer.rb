class MemberMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.member_mailer.send_authentication.subject
  #
  def send_authentication(email, session_url)
    @session_url = session_url
    mail to: email
  end

  def notify_event(event, event_url)
    @event = event
    @event_url = event_url
    mail to: event.group.members.map(&:email)
  end
end
