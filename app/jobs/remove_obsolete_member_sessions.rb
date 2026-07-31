class RemoveObsoleteMemberSessions < ApplicationJob
  def run
    MemberSession.transaction do
      MemberSession.where("created_at < ?", 6.hours.ago).delete_all
      destroy
      RemoveObsoleteMemberSessions.enqueue(job_options: { run_at: 4.hours.from_now })
    end
  end
end
