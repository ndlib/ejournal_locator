namespace :journals do
  desc "Process journal import files"
  task :import => :environment do
    Airbrake.configuration.rescue_rake_exceptions = true
    JournalImport.process_imports
  end

  task :index => :environment do
    puts "#{Time.now.strftime("%F %T")}: Updating Solr"
    Journal.update_solr
    puts "#{Time.now.strftime("%F %T")}: Solr Update Complete"
  end
end
