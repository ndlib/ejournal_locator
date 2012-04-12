class CreateJournalImports < ActiveRecord::Migration
  def change
    create_table :journal_imports do |t|
      t.integer :journal_count
      t.integer :holdings_count
      t.integer :provider_count
      t.integer :category_count
      t.boolean :complete, :default => false
      t.integer :import_file_size
      t.string :import_file_path
      t.text :error
      t.timestamps
    end

    add_column :journals, :first_import_id, :integer
    add_column :journals, :last_import_id, :integer
    add_index :journals, :first_import_id
    add_index :journals, :last_import_id
  end
end
