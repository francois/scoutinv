require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

STAGING = ENV.fetch("STAGING", "false") == "true"

WEB_IMAGE_CONFIG = {
  strip: true,
  quality: 80,
  resize: 1200,
}

module Scoutinv
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.i18n.available_locales = [ :fr, :en ]
    config.i18n.default_locale = :fr

    config.active_record.schema_format = :sql
  end
end
