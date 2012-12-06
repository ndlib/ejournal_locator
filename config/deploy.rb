#############################################################
#  Deployment Settings
#############################################################

#############################################################
#  Application
#############################################################
set :application, 'ejournal_locator'

#############################################################
#  Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, false

#############################################################
#  Source Control
#############################################################

set :scm, 'git'
set :scm_command,   '/usr/bin/git'
set :repository, "git@git.library.nd.edu:ejournal_locator"
# Set an environment variable to deploy from a branch other than master
# branch=beta cap staging deploy
set(:branch) {
  name = ENV['branch'] ? ENV['branch'] : 'master'

  if name == 'master'
    set :git_shallow_clone, 1
  end

  puts "Deploying to branch #{name}"
  name
}

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
  set :site_url,  'ejlpprd.library.nd.edu'

  set_common_deploy_variables()
end

desc "Setup for the Production environment"
task :production do
  set :rails_env, 'production'
  set :deploy_to, "/shared/ruby_prod/data/app_home/#{application}"
  set :ruby_bin,  '/shared/ruby_prod/ruby/1.9.3/bin'
  set :user,      'rbprod'
  set :domain,    'rprod.library.nd.edu'
  set :site_url,  'library.nd.edu'

  set_common_deploy_variables()
end

def set_common_deploy_variables
  ssh_options[:keys] = %w(/shared/jenkins/.ssh/id_dsa)
  ssh_options[:paranoid] = false

  set :ruby,      File.join(ruby_bin, 'ruby')
  set :bundler,   File.join(ruby_bin, 'bundle')
  set :rake,      File.join(shared_path, 'vendor/bundle/bin/rake')

  server "#{user}@#{domain}", :app, :web, :db, :primary => true
end

#############################################################
#  Passenger
#############################################################

desc "Restart Application"
task :restart_passenger do
  run "touch #{current_path}/tmp/restart.txt"
end

#############################################################
#  Deploy
#############################################################

namespace :deploy do
  desc "Start application in Passenger"
  task :start, :roles => :app do
    restart_passenger
  end

  desc "Restart application in Passenger"
  task :restart, :roles => :app do
    restart_passenger
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/log #{release_path}/log"
    run "mkdir -p #{release_path}/.bundle"
    run "ln -nfs #{shared_path}/bundle/config #{release_path}/.bundle/config"
    run "ln -nfs #{shared_path}/vendor/bundle #{release_path}/vendor/bundle"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Spool up Passenger spawner to keep user experience speedy"
  task :kickstart, :roles => :app do
    run "curl -I http://#{site_url}"
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

  desc "Run the migrate rake task"
  task :migrate, :roles => :app do
    run "cd #{release_path} && #{bundler} exec #{rake} RAILS_ENV=#{rails_env} db:migrate --trace"
  end

  # namespace :assets do
  #   desc "Run the asset clean rake task."
  #   task :clean, :roles => :app do
  #     run "cd #{release_path} && #{bundler} exec #{rake} RAILS_ENV=#{rails_env} RAILS_GROUPS=assets assets:clean"
  #   end
  #
  #   desc "Run the asset precompilation rake task."
  #   task :precompile, :roles => :app do
  #     run "cd #{release_path} && #{bundler} exec #{rake} RAILS_ENV=#{rails_env} RAILS_GROUPS=assets assets:precompile --trace"
  #   end
  # end

end

namespace :bundle do
  desc "Install gems in Gemfile"
  task :install, :roles => :app do
    run "#{bundler} install --binstubs='#{release_path}/vendor/bundle/bin' --shebang '#{ruby}' --gemfile='#{release_path}/Gemfile' --deployment"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared', 'bundle:install', 'deploy:migrate', 'deploy:reload_solr_core'#, 'deploy:assets:precompile'
after 'deploy', 'deploy:cleanup', 'deploy:restart', 'deploy:kickstart'
