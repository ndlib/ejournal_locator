class User < ActiveRecord::Base
  attr_accessible :email, :username
  
  devise :cas_authenticatable

  include Blacklight::User
end
