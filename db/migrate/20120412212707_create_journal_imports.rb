class CreateJournalImports < ActiveRecord::Migration
  def change
    create_table :journal_imports do |t|
      t.integer :journal_count, :default => 0
      t.integer :holdings_count, :default => 0
      t.integer :provider_count, :default => 0
      t.integer :category_count, :default => 0
      t.boolean :complete, :default => false
      t.integer :import_file_size, :default => 0
      t.string :import_file_path
      t.text :error_text
      t.timestamps
    end

    add_column :journals, :first_import_id, :integer
    add_column :journals, :last_import_id, :integer
    add_index :journals, :first_import_id
    add_index :journals, :last_import_id
  end
end
