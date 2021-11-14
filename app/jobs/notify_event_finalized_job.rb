class NotifyEventFinalizedJob < ApplicationJob
  def run(event_id)
    event = Event.find(event_id)
      MemberMailer.notify_event_finalized(event).deliver_now
  end
end
