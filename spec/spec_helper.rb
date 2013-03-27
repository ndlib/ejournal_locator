require 'rubygems'
require 'spork'


Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV["RAILS_ENV"] = 'test'

  # Trap methods to prevent model caching: https://github.com/sporkrb/spork/wiki/Spork.trap_method-Jujitsu
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  # factory_girl_rails was causing some model caching: http://stackoverflow.com/questions/4963733/spork-prefork-is-loading-app-models
  require 'factory_girl_rails'
  Spork.trap_class_method(FactoryGirl, :find_definitions)

  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    config.include Devise::TestHelpers, :type => :controller
    config.include LoginMacros, :type => :controller
    config.include Devise::TestHelpers, :type => :view
    config.include LoginMacros, :type => :view
    config.include Devise::TestHelpers, :type => :helper
    config.include LoginMacros, :type => :helper

    config.include ImportMacros
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

  FactoryGirl.reload
  Rails.application.reload_routes!

end
