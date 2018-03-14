# dcape-app-modperl Makefile
# the Makefile config and start special docker image with apache1.3 modperl and nginx

SHELL               = /bin/bash
CFG                ?= .env


# Site host
APP_SITE           ?= modperl.iac.tender.pro


# Docker image name
IMAGE              ?= abhinand12/apache1.3_modperl
# Docker image tag
IMAGE_VER         ?= 01
# Docker-compose project name (container name prefix)
PROJECT_NAME       ?= modperl
# dcape container name prefix
DCAPE_PROJECT_NAME ?= dcape
# dcape network attach to
DCAPE_NET          ?= $(DCAPE_PROJECT_NAME)_default
# dcape postgresql container name
#DCAPE_DB           ?= $(DCAPE_PROJECT_NAME)_db_1


# Docker-compose image tag
DC_VER             ?= 1.14.0

define CONFIG_DEF
# ------------------------------------------------------------------------------
# Mattermost settings

# Site host
APP_SITE=$(APP_SITE)

# Docker details

# Docker image name
IMAGE=$(IMAGE)
# Docker image tag
IMAGE_VER=$(IMAGE_VER)
# Docker-compose project name (container name prefix)
PROJECT_NAME=$(PROJECT_NAME)
# dcape network attach to
DCAPE_NET=$(DCAPE_NET)

endef
export CONFIG_DEF

-include $(CFG)
export

.PHONY: all $(CFG) start start-hook stop update up reup down docker-wait db-create db-drop psql dc help

all: help


# ------------------------------------------------------------------------------
# webhook commands
start: up

start-hook: reup

stop: down

update: reup

# ------------------------------------------------------------------------------
# docker commands
## старт контейнеров
up:
up: CMD=up -d
up: dc

## рестарт контейнеров
reup:
reup: CMD=up --force-recreate -d
reup: dc

## остановка и удаление всех контейнеров
down:
down: CMD=rm -f -s
down: dc

# ------------------------------------------------------------------------------
# $$PWD используется для того, чтобы текущий каталог был доступен в контейнере по тому же пути
# и относительные тома новых контейнеров могли его использовать
## run docker-compose
dc: docker-compose.yml
	@docker run --rm  \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $$PWD:$$PWD \
		-w $$PWD \
		docker/compose:$(DC_VER) \
		-p $$PROJECT_NAME \
		$(CMD)


$(CFG):
	@[ -f $@ ] || { echo "$$CONFIG_DEF" > $@ ; echo "Warning: Created default $@" ; }

# ------------------------------------------------------------------------------

## List Makefile targets
help:
	@grep -A 1 "^##" Makefile | less

##
## Press 'q' for exit
##
