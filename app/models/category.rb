class Category < ActiveRecord::Base
  has_many :journal_categories
  belongs_to :parent, :class_name => 'Category'

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :parent_id
end
