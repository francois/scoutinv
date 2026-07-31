# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 3 threads for minimum
# and maximum; this matches the current Rails Puma default.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 3 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Use clustered mode in environments that explicitly request multiple workers.
# Otherwise Puma runs in single-process mode, which keeps local development
# simple while retaining the configured thread pool above.
web_concurrency = ENV.fetch("WEB_CONCURRENCY", 0).to_i
if web_concurrency > 1
  workers web_concurrency
  preload_app!
else
  workers 0
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
