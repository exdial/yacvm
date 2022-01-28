linux: ## Linux
	@echo linux

mac: ## mac
	@echo mac

wrong-platform:
	@echo wrong platform


UNAME := $(shell uname)

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
