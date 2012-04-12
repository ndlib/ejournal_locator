class Provider < ActiveRecord::Base
  attr_accessible :title

  validates_presence_of :title
  validates_uniqueness_of :title

  def self.find_or_create_by_sfx_name(sfx_title)
    title = sfx_title.gsub(':Full Text','').strip
    self.find_or_create_by_title(title)
  end
end
