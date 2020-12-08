export POSTGRES_USER ?= postgres
export POSTGRES_PASSWORD ?=
export POSTGRES_DB ?= azione-decidim_production
export POSTGRES_HOST ?= pg
DUMP = pg_dump
RESTORE = pg_restore

CONTAINER = decidim

DECIDIM := docker exec -ti ${CONTAINER} $1
POSTGRES := docker exec -ti ${POSTGRES_HOST} psql -h ${POSTGRES_HOST} -U ${POSTGRES_USER} ${POSTGRES_DB} -c $1

CURR_TIME := $(shell date +"%Y%m%d%H%M%S")


.PHONY: tasks
tasks:
	$(DECIDIM) rails --tasks

# production usage utilities
pull:
	git checkout main && git pull && git checkout prod && git rebase main

decidim-logs:
	$(DECIDIM) cat log/production.log

# db management
dump:
	$(DECIDIM) ${DUMP} -h ${POSTGRES_HOST} -U ${POSTGRES_USER} ${POSTGRES_DB} > dump.psql
	docker cp ${CONTAINER}:/home/decidim/azione-decidim/db/dump.psql ./backup/$(CURR_TIME).psql

restore:
	docker cp ./backup/$(version).psql ${CONTAINER}:/home/decidim/azione-decidim/db/dump.psql
	@$(DECIDIM) ${RESTORE} -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -d ${POSTGRES_DB} ./db/dump.psql

migrate:
	$(DECIDIM) rails db:migrate

wipe:
	$(POSTGRES) "DROP SCHEMA public CASCADE;"
	$(POSTGRES) "CREATE SCHEMA public;"

databases:
	$(POSTGRES) "\l"

tables:
	$(POSTGRES) "\d"