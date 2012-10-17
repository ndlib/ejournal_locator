class Provider < ActiveRecord::Base
  attr_accessible :title

  validates_presence_of :title
  validates_uniqueness_of :title

  def self.clean_title(title)
    title.gsub(':Full Text','').strip
  end

  def self.find_or_create_by_sfx_name(sfx_title)
    title = self.clean_title(sfx_title)
    self.find_or_create_by_title(title)
  end
end
