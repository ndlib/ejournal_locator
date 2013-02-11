#!/bin/bash

cd /app

# Create a database.yml if it doesn't exists yet.
if [ ! -e "config/database.yml" ]
then
  cp config/database.yml.example config/database.yml
fi

# First attempt bundle install using local cache to save time.
bundle_local_result=$(bundle install --local)
if (( $? )) ; then
  # If the local install fails, try the regular bundle install
  bundle install
else
  # The bundle is already installed correctly.
  echo "Bundle already up to date."
fi

# If the databases have not been created yet, create them
if [ `mysql -e "SHOW DATABASES" -u root | grep -c '_development'` -eq 0 ]
then
  rake db:create
fi

rake db:migrate
