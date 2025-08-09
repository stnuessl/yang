#
# Copyright (C) 2025  Steffen Nuessle
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

Q :=

SHELL := bash -o pipefail

makefile := $(lastword $(MAKEFILE_LIST))
makedir := $(patsubst %/,%,$(dir $(makefile)))

PROJECT_NAME = yang
DOCKER_DIR := build/docker
TAG_PREFIX := $(PROJECT_NAME)

targets := \
	archlinux-setup

dirs := \
	$(DOCKER_DIR) \
	$(SCAN_DIR)

#
# Disable automatic deletion of intermediate files
#
.SECONDARY:

all: $(patsubst %,$(DOCKER_DIR)/%.ack,$(targets))

%: $(DOCKER_DIR)/%.ack
	$(Q)docker run \
		--interactive \
		--tty=$(if $(CMD),false,true) \
		--rm \
		--env CI \
		--env GITHUB_JOB \
		--env GITHUB_REF_NAME \
		--env GITHUB_RUN_ID \
		--env GITHUB_SHA \
		--env SOURCE_DATE_EPOCH \
		--env CCACHE_DISABLE=1 \
		--env UV_NO_CACHE=1 \
		--volume ${PWD}:/project/$(PROJECT_NAME) \
		--user $$(id -u):$$(id -g) \
		--workdir /project/$(PROJECT_NAME) \
		$(TAG_PREFIX):$* $(CMD)

$(DOCKER_DIR)/%.ack: $(makedir)/%/Dockerfile | $(dirs)
	$(Q)docker build --tag $(TAG_PREFIX):$* $(^D)
	@touch $@

docker-clean:
	docker image ls \
		| grep "$(TAG_PREFIX)" \
		| awk '{ print $$3 }' \
		| xargs --no-run-if-empty docker image rm --force
	rm -rf $(DOCKER_DIR)

$(dirs):
	mkdir -p $@

.PHONY: \
	all \
	docker-clean

.SILENT: \
	$(dirs) \
	docker-clean

