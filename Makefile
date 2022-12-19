# Set the Makefile default goal
.DEFAULT_GOAL := help

# Define the target .SILENT: to disable printing by default
# Use the "DEBUG=1" flag to make the process more talkative
# example: "make DEBUG=1 help"
ifndef DEBUG
.SILENT:
endif

# Fill AWS_PROFILE and AWS_REGION variables with the correct values
AWS_PROFILE := $(shell grep aws_profile terraform/inputs.hcl \
				| awk '{print $$3'} | tr -d '"''')
AWS_REGION  := $(shell grep aws_region terraform/inputs.hcl \
				| awk '{print $$3'} | tr -d '"''')

# Service targets (will never be called directly)
logo:
	clear
	head -n 14 README.md | tail -n 13
	echo

notice:
	echo "👨  Loaded AWS profile: $(AWS_PROFILE)"
	echo "📍  Loaded AWS region: $(AWS_REGION)"
	echo
	echo "Run \"make config\" to configure AWS account"
	echo "(or directly edit file terraform/inputs.hcl)"
	echo

check-mac: logo
	echo "🍏 Checking mac requirements..."
	command -v docker > /dev/null 2>&1 || \
		(echo "❌ ERROR: Docker is required."; \
		 echo "Visit https://docs.docker.com/desktop/mac/install/"; \
		 exit 1)
	echo "✅ OK..."

check-linux: logo
	echo "🐧 Checking linux requirements..."
	command -v docker > /dev/null 2>&1 || \
		(echo "❌ ERROR: Docker is required."; \
		 echo "Visit https://docs.docker.com/engine/install/"; \
		 exit 1)
	echo "✅ OK..."

wrong-platform: logo
	echo "❌ ERROR: Wrong platform"

# Interface targets
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	TARGET = check-mac build apply deploy clean
else ifeq ($(UNAME), Linux)
	TARGET = check-linux build apply deploy clean
else
	TARGET = wrong-platform
endif

# 🗄️ Common targets
install: $(TARGET) ## Install Holtzman-effect
config: logo ## Configure AWS account credentials
	read -p "👨  AWS profile [default]: " PROFILE; \
		echo "👨  Your AWS profile now is \"$$PROFILE\""; \
		sed -i.bak s/aws_profile.*/aws_profile\ =\ \"$$PROFILE\"/ \
		terraform/inputs.hcl
	read -p "📍  AWS region [us-east-1]: " REGION; \
		echo "📍 Your AWS region now is \"$$REGION\"" ; \
		sed -i.bak s/aws_region.*/aws_region\ =\ \"$$REGION\"/ \
		terraform/inputs.hcl

# 🌱 Terraform-related interface targets
build: logo ## Build docker image
	echo "🏗  Building the Docker image..."
	docker build -t holtzman-effect . -f Dockerfile
	echo "✅ OK..."
plan: logo ## Generate infrastructure plan without any changes
	echo "🏝  Running terraform plan..."
	docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		holtzman-effect sh -c "cd terraform && terragrunt plan"
	echo "✅ OK..."

apply: logo ## Apply the planned infrastructure
	echo "🏝  Running terraform apply..."
	docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		holtzman-effect sh -c "cd terraform && terragrunt apply"
	echo "✅ OK..."

# 🚀 Ansible-related interface targets
ping: logo ## Run ansible and ping the target server
	echo "🏝  Running Ansible ping..."
	docker run --rm -v `pwd`:/code holtzman-effect sh -c \
		"cd ansible && ansible all -m ping"
	echo "✅ OK..."
deploy: logo ## Deploy the ansible playbook
	echo "🏝  Running Ansible playbook..."
	docker run --rm -v `pwd`:/code holtzman-effect sh -c \
		"cd ansible && ansible-playbook site.yml"
	echo "✅ OK..."
destroy: logo ## Destroy deployed infrastructure
	echo "🏝  Destroying deployed infrastructure..."
	docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		holtzman-effect sh -c "cd terraform && terragrunt destroy"
	echo "✅ OK..."
clean: logo ## Cleanup files produced by Holtzman-effect
	echo "🧹  Cleanup..."
	rm -f ansible/ubuntu-bionic-18.04-cloudimg-console.log \
		terraform/_setup.tf terraform/_backend.tf \
		terraform/inputs.hcl.bak
	rm -rf ansible/.vagrant
	echo "✅ OK..."

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: logo notice ## Display this info
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: *