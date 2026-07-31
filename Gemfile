source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.7'

gem 'rails', '~> 7.0.10'
# Rails 7 no longer depends on Sprockets, but this application still uses it.
gem 'sprockets-rails'
gem 'pg'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

gem 'mimemagic', '> 0.3.4'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bcrypt', '~> 3.1.7'
gem 'aws-sdk-s3'
gem 'kaminari', '~> 1.2'
gem 'que', github: "que-rb/que", ref: "master"
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
  gem 'capybara', '~> 2.15'
  gem 'webdrivers'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end
