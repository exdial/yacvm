docker-build: ## Build docker image
	@clear && head -n 16 README.md | tail -n13 && echo
	@docker build -t holtzman-effect . -f Dockerfile

check: ## Check all requirements are met
	@echo "Checking requirements..."
	@command -v docker > /dev/null 2>&1 || \
		(echo "❌ ERROR: Docker is required. \nVisit https://docs.docker.com/get-docker/"; exit 1)
	@command -v vagrant > /dev/null 2>&1 || \
		(echo "❌ ERROR: Vagrant is required. \nVisit https://www.vagrantup.com/"; exit 1)
	@echo "✅ Done..."

test: ## Run tests
	@clear && head -n 16 README.md | tail -n13 && echo
	@cd $(CWD)/ansible && vagrant up

clean: ## Stop tests and delete all files produced by the Holtzman effect
	cd $(CWD)/ansible && vagrant destroy -f
	rm -f $(CWD)/ansible/ubuntu-bionic-18.04-cloudimg-console.log
	rm -rf $(CWD)/ansible/.vagrant

linux: ## Linux
	@echo linux

mac: ## mac
	@echo mac

wrong-platform:
	@echo wrong platform


UNAME := $(shell uname)
CWD   := $(shell pwd)

ifeq ($(UNAME), Linux)
  TARGET = linux
else ifeq ($(UNAME), Darwin)
	TARGET = mac
else
	TARGET = wrong-platform
endif

install: $(TARGET)

.PHONY: linux mac wrong-platform

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
