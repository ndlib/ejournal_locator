class Category < ActiveRecord::Base
  has_many :journal_categories
  belongs_to :parent, :class_name => 'Category'
  has_many :subcategories, :class_name => 'Category', :foreign_key => 'parent_id'

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :parent_id

  def title_with_parent
    if parent.present?
      "#{parent.title}/#{title}"
    else
      title
    end
  end
end
