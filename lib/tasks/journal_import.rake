namespace :journals do
  desc "Process journal import files"
  task :import => :environment do
    JournalImport.process_imports
  end
end