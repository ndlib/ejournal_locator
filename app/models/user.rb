class User < ActiveRecord::Base
  attr_accessible :email
  
  devise :cas_authenticatable

  include Blacklight::User
end
