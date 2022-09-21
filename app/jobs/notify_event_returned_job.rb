class NotifyEventReturnedJob < ApplicationJob
  def run(event_id)
    event = Event.find(event_id)
    MemberMailer.notify_event_returned(event).deliver_now
    destroy
  end
end
