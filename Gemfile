source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'blacklight', '~> 4.2.0'
gem 'bootstrap-sass' # used by blacklight
gem 'capistrano', '~> 2.8.0'
gem 'devise'
gem 'devise_cas_authenticatable'
gem 'devise-guests'
gem 'exception_notification'
gem 'hesburgh_assets', :git => 'git@git.library.nd.edu:assets'
gem 'json'
gem 'jquery-rails', '~> 2.1.4'
gem 'mysql2'
gem 'nokogiri', '~> 1.5.0'
gem 'twitter-bootstrap-rails'
gem 'unicode' # used by blacklight

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', '~> 0.10.0'

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem "better_errors"
end

group :test, :development do
  gem 'pry-rails' # Debugger replacements.  Use "binding.pry" where you would use "debugger"
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails', :require => false

  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false

  gem 'guard-rspec'
  gem 'guard-coffeescript'
  gem 'guard-rails'
  gem 'guard-bundler'
  gem 'guard-spork'

  gem 'faker'
  gem 'growl'
  gem 'rb-readline'
end
