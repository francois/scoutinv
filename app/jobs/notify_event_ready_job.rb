class NotifyEventReadyJob < ApplicationJob
  def run(event_id)
    event = Event.find(event_id)
    MemberMailer.notify_event_ready(event).deliver_now
    destroy
  end
end
