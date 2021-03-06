#!/bin/bash

# Begin Java
if _java_path=$(type -p java); then
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then   
    _java="$JAVA_HOME/bin/java"
fi

if [ -z "$_java" ]; then
  java_version=0
else
  java_version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
fi

if [[ "$java_version" < "1.7" ]]; then
  # Install Java 1.7
  cd /tmp
  yum -y install jpackage-utils
  wget http://download.oracle.com/otn-pub/java/jdk/7u7-b10/jdk-7u7-linux-i586.rpm
  rpm -Uvh jdk-7u7-linux-i586.rpm
  rm jdk-7u7-linux-i586.rpm
else
  echo "Java version: $java_version"
fi
# End Java

# If the .bash_profile does not already have a `cd /app` command, add it.
if [ `grep -c "cd /app" /home/vagrant/.bash_profile` -eq 0 ]
then
  echo "cd /app" >> /home/vagrant/.bash_profile
fi

# Run the rest as vagrant
su - vagrant -c /app/provision-vagrant.sh
