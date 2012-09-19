#!/bin/bash

# If the .bash_profile does not already have a `cd /app` command, add it.
if [ `grep -c "cd /app" /home/vagrant/.bash_profile` -eq 0 ]
then
  echo "cd /app" >> /home/vagrant/.bash_profile
fi

cd /app

# Create a database.yml if it doesn't exists yet.
if [ ! -e "config/database.yml" ]
then
  cp config/database.yml.example config/database.yml
fi

bundle install

# If the databases have not been created yet, create them
# if [ `mysql -e "SHOW DATABASES" -u root | grep -c '_development'` -eq 0 ]
# then
rake db:create
# fi

rake db:migrate
