class ApplicationJob < Que::Job
  delegate :logger, to: Rails
end
