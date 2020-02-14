source 'https://rubygems.org'

group :application do
  gem 'rails', '~> 3.2.13'

  gem 'blacklight', '~> 4.2.0'
  gem 'bootstrap-sass' # used by blacklight
  gem 'devise'
  gem 'devise_cas_authenticatable'
  gem 'devise-guests'
  gem 'exception_notification'
  gem 'hesburgh_assets', :git => 'https://github.com/ndlib/assets.git', :ref => '787e6c8f6d38a981d8face7c2b4ada1910ea0291'
  gem 'hesburgh_infrastructure', :git => 'https://github.com/ndlib/hesburgh_infrastructure'
  gem 'json'
  gem 'jquery-rails', '~> 2.1.4'
  gem 'mysql2', '0.3.21'
  gem 'nokogiri', '1.10.4'
  gem "rb-readline"
  gem 'twitter-bootstrap-rails'
  gem 'unicode' # used by blacklight
end

gem "capistrano", "2.15.5"

gem 'newrelic_rpm'

# For Errbit
gem "airbrake"

gem "whenever", :require => false

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem "better_errors"
end

group :development, :test do
  gem "debugger"
  gem "rspec-rails"
  gem "capybara"
  gem "factory_girl_rails", :require => false
  gem "faker"

  gem "guard", '~> 1.8'
  gem "guard-bundler"
  gem "guard-coffeescript"
  gem "guard-rails"
  gem "guard-rspec"
  gem "guard-spork"
  gem "guard-jetty"
  gem "growl"
end
