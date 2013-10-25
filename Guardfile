require 'hesburgh_infrastructure'
# application_name must match an application in the hesburgh_infrastructure gem
# New applications must be added to config/applications.yml in hesburgh_infrastructure
hesburgh_guard = HesburghInfrastructure::Guard.new(:ejournal_locator, self)

# Automatically compile CoffeeScript files
# https://github.com/guard/guard-coffeescript
hesburgh_guard.coffeescript

# Automatically install/update your gem bundle when needed
# https://github.com/guard/guard-bundler
hesburgh_guard.bundler gemspec: false do
  # Watch any custom paths
end

# Automatically start/restart your Rails development server
# https://github.com/ranmocy/guard-rails
hesburgh_guard.rails do
  # Watch any custom paths
end

guard 'jetty', jetty_port: hesburgh_guard.application.jetty_port do
  watch('config/jetty.yml')
  watch(%r{^jetty/(.+)\.xml$})
end

# Intelligently start/reload your RSpec Drb spork server
# https://github.com/guard/guard-spork
hesburgh_guard.spork do
  # Watch any custom paths
end

# Automatically run your specs
# https://github.com/guard/guard-rspec
hesburgh_guard.rspec do
  # Watch any custom paths
end
