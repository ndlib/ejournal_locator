# Architecture Drawings

Search tool for the Hesburgh Library's collection of electronic journals

https://ejl.library.nd.edu/
https://ejlpprd.library.nd.edu/

## Installation

```sh
bundle install
cp config/database.yml.example config/database.yml
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:migrate RAILS_ENV=test
```

## Running
```sh
bundle exec guard
```

## Adding test data
```sh
cp spec/files/jst_journal_archive_full.xml import/jst_journal_archive_full.xml-marc
bundle exec rake journals:import
```

## Searching

Searching can be done from http://localhost:3006/

## Deploy

Deployed via Jenkins: https://jenkins-vm.library.nd.edu/jenkins/job/eJournal%20Locator/
