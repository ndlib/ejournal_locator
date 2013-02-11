require 'lib/deploy/passenger'
# List all tasks from RAILS_ROOT using: cap -T

# NOTE: The SCM command expects to be at the same path on both the local and
# remote machines. The default git path is: '/shared/git/bin/git'.

#############################################################
#  Configuration
#############################################################
set :application, 'ejournal_locator'
set :repository,  'git@git.library.nd.edu:ejournal_locator'
ssh_options[:keys] = %w(/shared/jenkins/.ssh/id_dsa)

set :symlink_targets, [
  { '/bundle/config' => '/.bundle/config' },
  '/log',
  '/vendor/bundle',
  '/config/database.yml',
  '/import'
]

#############################################################
#  Environments
#############################################################

desc "Setup for the Pre-Production environment"
task :pre_production do
  set :rails_env, 'pre_production'
  set :deploy_to, "/shared/ruby_pprd/data/app_home/#{application}"
  set :ruby_bin,  '/shared/ruby_pprd/ruby/1.9.3/bin'

  set :user,      'rbpprd'
  set :domain,    'ejlpprd.library.nd.edu'

  server "#{user}@#{domain}", :app, :web, :db, :primary => true
end

desc "Setup for the Production environment"
task :production do
  set :rails_env, 'production'
  set :deploy_to, "/shared/ruby_prod/data/app_home/#{application}"
  set :ruby_bin,  '/shared/ruby_prod/ruby/1.9.3/bin'

  set :user,      'rbprod'
  set :domain,    'rprod.library.nd.edu'

  server "#{user}@#{domain}", :app, :web, :db, :primary => true
end

#############################################################
#  Deploy
#############################################################

namespace :deploy do
  desc "Prepare symlink_shared"
  task :prepare_symlink_shared, :roles => :app do
    run "rm -rf #{release_path}/import"
  end

  desc "Reload the Solr configuration"
  task :reload_solr_core, :roles => :app do
    solr_config = YAML.load_file("#{release_path}/config/solr.yml")[rails_env.to_s]
    core_url = solr_config["url"]
    core_regex = /[^\/]+$/
    core_name = core_url.match(core_regex)[0]
    base_solr_url = core_url.gsub(core_regex,'')
    reload_url = base_solr_url + "admin/cores?action=RELOAD&core=" + core_name
    puts "Reloading solr core: #{reload_url}"
    run "curl -I -A \"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)\" #{reload_url}"
  end
end

after 'deploy:symlink_shared', 'deploy:reload_solr_core'
before 'deploy:symlink_shared', 'deploy:prepare_symlink_shared'
