class ApplicationController < ActionController::Base
  define_callbacks :logging_in_user
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  layout 'application'
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  protect_from_forgery
end
