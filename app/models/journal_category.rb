class JournalCategory < ActiveRecord::Base
  attr_accessible :journal_id, :category_id

  belongs_to :journal
  belongs_to :category
end
