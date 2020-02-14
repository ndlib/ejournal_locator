#!/bin/bash
bash docker/wait-for-it.sh -t 120 ${DB_HOST}:3306
bundle exec rails runner -e production 'User.destroy_temporary_users()'
RAILS_ENV=production bundle exec rake blacklight:delete_old_searches[7] --silent