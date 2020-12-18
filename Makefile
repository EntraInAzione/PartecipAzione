export POSTGRES_USER ?= postgres
export POSTGRES_PASSWORD ?=
export POSTGRES_DB ?= azione-decidim_production
export POSTGRES_HOST ?= pg
DUMP = pg_dump
RESTORE = pg_restore

CONTAINER = decidim

DECIDIM := @docker exec -ti ${CONTAINER} $1
POSTGRES := @docker exec -ti ${POSTGRES_HOST} psql -h ${POSTGRES_HOST} -U ${POSTGRES_USER} ${POSTGRES_DB} -c $1

CURR_TIME := $(shell date +"%Y%m%d%H%M%S")

default: install up 

install:
	./scripts/install.sh

up:
	docker-compose up -d

down: 
	docker-compose down

# decidim commands
decidim:
	@docker exec -ti ${CONTAINER} bash

decidim-logs:
	$(DECIDIM) cat log/production.log

decidim-live-logs:
	$(DECIDIM) tail log/production.log -f

decidim-logs-errors:
	$(DECIDIM) grep ERROR log/production.log -A3 -B3

tasks:
	$(DECIDIM) rails --tasks

# db management
db:
	@docker exec -ti ${POSTGRES_HOST} psql -h ${POSTGRES_HOST} -U ${POSTGRES_USER} ${POSTGRES_DB}

db-dump:
	$(DECIDIM) ${DUMP} -h ${POSTGRES_HOST} -U ${POSTGRES_USER} ${POSTGRES_DB} > dump.psql
	@docker cp ${CONTAINER}:/home/decidim/azione-decidim/db/dump.psql ./backup/$(CURR_TIME).psql

db-restore:
	@docker cp ./backup/$(version).psql ${CONTAINER}:/home/decidim/azione-decidim/db/dump.psql
	$(DECIDIM) ${RESTORE} -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -d ${POSTGRES_DB} ./db/dump.psql

db-migrate:
	$(DECIDIM) rails db:migrate

db-migrate-status:
	$(DECIDIM) rails db:migrate:status

db-wipe:
	$(POSTGRES) "DROP SCHEMA public CASCADE;"
	$(POSTGRES) "CREATE SCHEMA public;"

db-list:
	$(POSTGRES) "\l"

db-tables:
	$(POSTGRES) "\d"

# analysis commands
users-count:
	$(POSTGRES) "SELECT count(id) FROM public.decidim_users;" | sed '3q;d'

# production usage utilities
pull:
	git checkout main && git pull && git checkout prod && git rebase main
