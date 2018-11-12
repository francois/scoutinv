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

  def notify_event_finalized(event)
    @event = event
    @event_url = event_url(event)
    mail to: event.group.inventory_directors.map(&:email)
  end

  def notify_event_ready(event)
    return unless event.internal?

    @event = event
    @event_url = event_url(event)
    mail to: event.troop.members.map(&:email)
  end

  def notify_event_returned(event)
    return unless event.internal?

    @event = event
    @event_url = event_url(event)

    author = event.group.inventory_directors.first
    generator =
      if @event.internal?
        TroopContractPdfPrinter.new(@event, author: author)
      else
        ExternalRenterContractPdfPrinter.new(@event, author: author)
      end

    # Attach the contract PDF
    attachments[generator.filename] = generator.print

    mail to: event.troop.members.map(&:email),
      cc: (event.group.inventory_directors + event.group.accountants).map(&:email)
  end
end
