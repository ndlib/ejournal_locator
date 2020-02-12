
# Docker

## Installation

```sh
docker-compose build
```

## Running

### Development

```sh
docker-compose up
docker-compose exec rails bundle exec rake db:schema:load
open http://localhost:3000
```

### Production

Production will additionally run an nginx container to serve out static assets. To run it in this mode locally, do the following:

```sh
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
open http://localhost
```

When running in this mode, you will want to hit the web service at http://localhost, otherwise static assets will not be served correctly. The application service will still be exposed on port 3000, so you can reach it directly at http://localhost:3000 if needed.

## Adding test data

```sh
docker-compose exec rails cp spec/files/jst_journal_archive_full.xml import/jst_journal_archive_full.xml-marc
docker-compose exec rails bundle exec rake journals:import
```

## Importing data

This will import the current daily data from SFX into the running rails container.

```sh
docker-compose exec rails curl https://findtext.library.nd.edu/ndu_local/cgi/public/get_file.cgi?file=EJournal_Locator_Daily.xml -o import/ejl-full-e-collection-ALL.xml-marc
docker-compose exec rails bundle exec rake journals:import
```
