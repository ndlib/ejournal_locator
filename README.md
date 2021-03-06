# eJournal Locator

Search tool for the Hesburgh Library's collection of electronic journals

https://ejl.library.nd.edu/
https://ejl-test.library.nd.edu/

Note: See [Docker Readme](docker/README.md) for alternate instructions on running with Docker

Visit the Service Runbook: [eJournal Locator](https://github.com/ndlib/TechnologistsPlaybook/tree/master/run-books/ejournal-locator.md)


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
bundle exec rake journals:index
```

## Searching

Searching can be done from http://localhost:3006/

## Deploy

Deployed via Jenkins: https://jenkins-vm.library.nd.edu/jenkins/job/eJournal%20Locator/

## Cron tasks

Cron tasks are configured in `config/schedule.rb`

### rake journals:import
The import task reads files from `import/*.xml-marc`
In pre_production and production environments, an external cron task (managed by Tom Hanstra) copies exports from SFX to the ejournal locator import folder for processing.

## Smoke Tests

Requires [Newman cli](https://github.com/postmanlabs/newman)

```sh
newman run spec/postman/collection.json --folder Smoke \
  --env-var host=<hostname>
```
