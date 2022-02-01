MAKEFLAGS += --silent

AWS_PROFILE := $(shell cat terraform/inputs.hcl | grep aws_profile \
																								| awk '{print $$3}' \
																								| tr -d '"''')
AWS_REGION  := $(shell cat terraform/inputs.hcl | grep aws_region \
																								| awk '{print $$3}' \
																								| tr -d '"''')

logo:
	@clear
	@head -n 16 README.md | tail -n 13
	@echo

notice:
	@echo "🔑 You're using AWS profile: $(AWS_PROFILE)"
	@echo "🔑 You're using AWS region: $(AWS_REGION)"
	@echo
	@echo "Run \"make config\" to configure AWS"
	@echo "credentials or edit terraform/inputs.hcl"
	@echo

check-mac: logo notice
	@echo "🍏 Checking mac requirements..."
	@command -v docker > /dev/null 2>&1 || \
		(echo "❌ ERROR: Docker is required."; \
		 echo "Visit https://docs.docker.com/desktop/mac/install/"; \
		 exit 1)
	@command -v vagrant > /dev/null 2>&1 || \
		(echo "❌ ERROR: Vagrant is required."; \
		 echo "Visit https://www.vagrantup.com/"; \
		 exit 1)
	@echo "✅ Done..."

check-linux: logo notice
	@echo "🐧 Checking linux requirements..."
	@command -v docker > /dev/null 2>&1 || \
		(echo "❌ ERROR: Docker is required."; \
		 echo "Visit https://docs.docker.com/engine/install/"; \
		 exit 1)
	@command -v vagrant > /dev/null 2>&1 || \
		(echo "❌ ERROR: Vagrant is required."; \
		 echo "Visit https://www.vagrantup.com/"; \
		 exit 1)
	@echo "✅ Done..."

wrong-platform: logo notice
	@echo "❌ Wrong platform"

config: logo ## Configure AWS credentials
	@read -p "AWS profile [default]: " PROFILE; \
	 echo "🔑 You've choosen the profile \"$$PROFILE\""; \
	 sed -i.bak s/aws_profile.*/aws_profile\ =\ \"$$PROFILE\"/ \
		terraform/inputs.hcl
	@read -p "AWS region [us-east-1]: " REGION; \
	 echo "🔑 You've choosen the region \"$$REGION\"" ; \
	 sed -i.bak s/aws_region.*/aws_region\ =\ \"$$REGION\"/ \
		terraform/inputs.hcl

build: logo ## Build docker image
	@echo "🏗  Running docker build..."
	@docker build -t holtzman-effect . -f Dockerfile
	@docker system prune -f
	@echo "✅ Done..."

plan: logo notice ## Plan infrastructure without changes
	@echo "🏝 Running terraform plan..."
	@docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
  	holtzman-effect sh -c "cd terraform && terragrunt plan"
	@echo "✅ Done..."

apply: logo notice ## Apply the planned infrastructure in the real world
	@echo "🏝 Running terraform apply..."
	@docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
  	holtzman-effect sh -c "cd terraform && terragrunt apply"
	@echo "✅ Done..."

ping: logo notice ## Run ansible and ping the server
	@echo "🏝 Running Ansible ping..."
	@docker run --rm -v `pwd`:/code holtzman-effect sh -c \
		"cd ansible && ansible all -m ping"
	@echo "✅ Done..."

deploy: logo notice ## Deploy the ansible playbook
	@echo "🏝 Running Ansible playbook..."
	@docker run --rm -v `pwd`:/code holtzman-effect sh -c \
		"cd ansible && ansible-playbook site.yml"
	@echo "✅ Done..."

destroy: logo notice ## Destroy deployed infrastructure
	@echo "🏝  Destroying deployed infrastructure..."
	@docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		holtzman-effect sh -c "cd terraform && terragrunt destroy"
	@echo "✅ Done..."

clean: logo notice ## Cleanup files produced by Holtzman-effect
	@echo "Cleanup..."
	@rm -f ansible/ubuntu-bionic-18.04-cloudimg-console.log \
				 terraform/_setup.tf terraform/_backend.tf \
				 terraform/inputs.hcl.bak
	@rm -rf ansible/.vagrant
	@pushd ansible && vagrant destroy -f && popd
	@echo "✅ Done..."

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	TARGET = check-mac build apply deploy clean
else ifeq ($(UNAME), Linux)
	TARGET = check-linux build apply deploy clean
else
	TARGET = wrong-platform
endif

install: $(TARGET) ## Install Holtzman-effect

.PHONY: help

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: logo notice ## Display this info
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
   awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
