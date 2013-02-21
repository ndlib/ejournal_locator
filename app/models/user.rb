class User < ActiveRecord::Base
  attr_accessible :email, :username
  attr_accessor :password, :password_confirmation # Hack to allow devise-guests to work for now
  
  devise :cas_authenticatable

  include Blacklight::User
end
