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
  ssh_options[:keys] = %w(/shared/jenkins/.ssh/id_dsa)
  ssh_options[:paranoid] = false

  set :rails_env, 'pre_production'
  set :deploy_to, "/shared/ruby_pprd/data/app_home/#{application}"
  set :ruby_bin,  '/shared/ruby_pprd/ruby/1.9.3/bin'
  set :ruby,      File.join(ruby_bin, 'ruby')
  set :bundler,   File.join(ruby_bin, 'bundle')
  set :rake,      File.join(shared_path, 'vendor/bundle/ruby/1.8/bin/rake')
  set :user,      'rbpprd'
  set :domain,    'ejlpprd.library.nd.edu'
  set :site_url,  'ejlpprd.library.nd.edu'

  server "#{user}@#{domain}", :app, :web, :db, :primary => true
end

desc "Setup for the Production environment"
task :production do
  ssh_options[:keys] = %w(/shared/jenkins/.ssh/id_dsa)
  ssh_options[:paranoid] = false

  set :rails_env, 'production'
  set :deploy_to, "/shared/ruby_prod/data/app_home/#{application}"
  set :ruby_bin,  '/shared/ruby_prod/ruby/1.9.3/bin'
  set :ruby,      File.join(ruby_bin, 'ruby')
  set :bundler,   File.join(ruby_bin, 'bundle')
  set :rake,      File.join(shared_path, 'vendor/bundle/ruby/1.8/bin/rake')
  set :user,      'rbprod'
  set :domain,    'rprod.library.nd.edu'
  set :site_url,  'library.nd.edu'

  # Set the default path to make a custom version of python available for libv8
  set :default_environment, {
    'PATH' => "/shared/python/bin/:$PATH:#{ruby_bin}"
  }

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
    run "#{bundler} install --gemfile='#{release_path}/Gemfile'"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared', 'bundle:install', 'deploy:migrate'#, 'deploy:assets:precompile'
after 'deploy', 'deploy:cleanup', 'deploy:restart', 'deploy:kickstart'
