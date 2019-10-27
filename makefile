# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

include .env
## the line below should only be commented out if you want to use `make login` AFTER the jupyterhub has been built.
include secrets/oauth.env

.DEFAULT_GOAL=build

network:
	@docker network inspect $(HUB_NAME)-network >/dev/null 2>&1 || docker network create $(HUB_NAME)-network

volumes:
	@docker volume inspect $(HUB_NAME)-data >/dev/null 2>&1 || docker volume create --name $(HUB_NAME)-data
	@docker volume inspect $(HUB_NAME)-db-data >/dev/null 2>&1 || docker volume create --name $(HUB_NAME)-db-data

secrets/postgres.env:
	@echo "Generating postgres password in $@"
	@echo "POSTGRES_PASSWORD=$(shell openssl rand -hex 32)" > $@

secrets/oauth.env:
	@echo "Generating hash key in $@"
	@echo "HASH_SECRET_KEY=$(shell openssl rand -hex 32)" > $@

login:
	@docker run --rm $(HUB_NAME) hashauthpw --length $(PASSWORD_LENGTH) $(USERNAME) $(HASH_SECRET_KEY)

secrets/jupyterhub.crt:
	@echo "Need an SSL certificate in secrets/jupyterhub.crt"
	@exit 1

secrets/jupyterhub.key:
	@echo "Need an SSL key in secrets/jupyterhub.key"
	@exit 1

userlist:
	@echo "Add usernames, one per line, to ./userlist, such as:"
	@echo "    zoe admin"
	@echo "    wash"

# Do not require cert/key files if SECRETS_VOLUME defined
#secrets_volume = $(shell echo $(SECRETS_VOLUME))
#ifeq ($(secrets_volume),)
#	cert_files=secrets/jupyterhub.crt secrets/jupyterhub.key
#else
#	cert_files=
#endif

check-files: userlist secrets/postgres.env secrets/oauth.env

pull:
	docker pull $(DOCKER_NOTEBOOK_IMAGE)

notebook_image: pull singleuser/Dockerfile
	docker build -t $(HUB_NAME)-user:latest \
		--build-arg JUPYTER_ENABLE_LAB=$(JUPYTER_ENABLE_LAB) \
		--build-arg JUPYTERHUB_VERSION=$(JUPYTERHUB_VERSION) \
		--build-arg DOCKER_NOTEBOOK_IMAGE=$(DOCKER_NOTEBOOK_IMAGE) \
		--build-arg DISPLAY=$(DISPLAY) \
		singleuser

build: check-files network volumes
	docker-compose build

.PHONY: network volumes check-files pull notebook_image build
