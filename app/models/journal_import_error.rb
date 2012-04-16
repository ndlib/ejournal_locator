class JournalImportError < ActiveRecord::Base
  attr_accessible :journal_import_id, :error_type, :exception_message, :exception_backtrace, :journal_xml
  
  belongs_to :journal_import
end
