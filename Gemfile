source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.5'

gem 'rails', '~> 8.1.0'
# Ruby 4 no longer includes this as a default gem; MiniMagick requires it at boot.
gem 'benchmark'
gem 'propshaft'
gem 'pg'
gem 'puma', '~> 8.0'

gem 'mimemagic', '> 0.3.4'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bcrypt', '~> 3.1.7'
gem 'aws-sdk-s3'
gem 'kaminari', '~> 1.2'
gem 'que', github: "que-rb/que", ref: "v2.4.1"
# The 0.202 line deadlocks with Rails 7.0 transaction handling.
gem 'state_machines', '~> 0.20.0'
gem 'state_machines-activerecord', '~> 0.8.0'
gem 'prawn'
gem 'prawn-table'

# Use ActiveStorage variant
gem 'image_processing', '~> 1.2'
gem 'mini_magick', '~> 4.8'

# Performance and exception monitoring
gem 'scout_apm'
gem 'sentry-raven'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'hookup'
end

group :development do
  gem 'bullet'
  gem 'listen', '~> 3.5'
  gem 'spring', '>= 3.0.0'
  gem 'spring-watcher-listen', '>= 2.1.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  # Keep Minitest 5 while the legacy test suite is modernized separately.
  gem 'minitest', '< 6'
  gem 'capybara', '~> 3.40'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end
