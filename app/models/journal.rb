class Journal < ActiveRecord::Base

  has_many :journal_categories, :dependent => :destroy
  has_many :categories, :through => :journal_categories

  validates_presence_of :title, :sfx_id
  validates_uniqueness_of :sfx_id

end
