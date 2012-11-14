class CreateJournalCategories < ActiveRecord::Migration
  def change
    create_table :journal_categories, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :journal_id
      t.integer :category_id
      t.timestamps
    end

    add_index :journal_categories, :journal_id
    add_index :journal_categories, :category_id
  end
end
