class ChangeImportErrorExceptionMessage < ActiveRecord::Migration
  def up
    change_column(:journal_import_errors, :exception_message, :text)
  end

  def down
    change_column(:journal_import_errors, :exception_message, :string)
  end
end
