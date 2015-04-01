class User < ActiveRecord::Base
  attr_accessible :email, :username
  attr_accessor :password, :password_confirmation # Hack to allow devise-guests to work for now

  validates_uniqueness_of :username, allow_nil: true

  devise :cas_authenticatable

  include Blacklight::User

  def self.destroy_temporary_users(number_of_days = 7, group_size = 1000)
    # Temporarily disable logging
    logger_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = 1
    current_offset = 0
    users = self.expired_temporary_users(number_of_days)
    users_count = users.count
    puts "#{self.to_s}#destroy_temporary_users: #{users_count} guest users over #{number_of_days} days old in database."
    while current_offset < users_count
      users_to_destroy = users.order(:created_at).includes(:bookmarks, :searches).limit(group_size)
      destroy_count = users_to_destroy.count
      puts "Destroying temporary users #{current_offset + 1} through #{current_offset + destroy_count}"
      users_to_destroy.destroy_all
      current_offset += destroy_count
    end
    puts "#{self.to_s}#destroy_temporary_users: Successfully destroyed #{users_count} guest user records."
    ActiveRecord::Base.logger.level = logger_level
  end

  def self.temporary_users
    where(username: nil)
  end

  def self.expired_temporary_users(number_of_days = 7)
    self.temporary_users.where("created_at < ?", number_of_days.days.ago)
  end
end
