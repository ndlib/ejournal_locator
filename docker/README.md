
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
```

### Production

Production will additionally run an nginx container to serve out static assets. To run it in this mode locally, do the following:

```sh
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

## Adding test data

```sh
docker-compose exec rails cp spec/files/jst_journal_archive_full.xml import/jst_journal_archive_full.xml-marc
docker-compose exec rails bundle exec rake journals:import
```
