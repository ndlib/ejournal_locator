namespace :journals do
  desc "Process journal import files"
  task :import => :environment do
    begin
      JournalImport.process_imports
    rescue StandardError => e
      NotifyError.call(e)
      raise e
    end
  end
end
