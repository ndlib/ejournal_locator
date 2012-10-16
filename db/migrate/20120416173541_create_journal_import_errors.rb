class CreateJournalImportErrors < ActiveRecord::Migration
  def change
    create_table :journal_import_errors do |t|
      t.integer :journal_import_id
      t.string :error_type
      t.string :exception_message
      t.text :exception_backtrace
      t.text :journal_xml
      t.timestamps
    end

    add_index :journal_import_errors, :journal_import_id
  end
end
