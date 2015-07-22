namespace :journals do
  desc "Process journal import files"
  task :import => :environment do
    Airbrake.configuration.rescue_rake_exceptions = true
    JournalImport.process_imports
  end
end
