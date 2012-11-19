class User < ActiveRecord::Base
  attr_accessible :email
  
  devise :cas_authenticatable
end
