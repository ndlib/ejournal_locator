# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

set :bundler, "bundle"

if environment == 'pre_production' || environment == 'production'
  set :rails_exec, 'vendor/bundle/bin/rails'
  set :rake_exec, 'vendor/bundle/bin/rake'
else
  set :rails_exec, 'rails'
  set :rake_exec, 'rake'
end

job_type :runner, "cd :path && :bundler exec :rails_exec runner -e :environment ':task' :output"
job_type :rake,   "cd :path && :environment_variable=:environment :bundler exec :rake_exec :task --silent :output"

# Learn more: http://github.com/javan/whenever

every '0 12 * * *' do
  runner "User.destroy_temporary_users()"
  rake "blacklight:delete_old_searches[7]"
end

every '0 4 * * *' do
  rake "journals:import"
end
