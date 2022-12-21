# Set the Makefile default goal
.DEFAULT_GOAL := help

# Define target .SILENT: to disable printing by default
# Use the "DEBUG=1" flag to make process more talkative
# example: "make DEBUG=1 help"
ifndef DEBUG
.SILENT:
endif

# Load variables from external file to show them in the main menu
AWS_PROFILE           := $(shell grep aws_profile terraform/inputs.hcl \
				          | awk '{print $$3'} | tr -d '"''')
AWS_REGION            := $(shell grep aws_region terraform/inputs.hcl \
				          | awk '{print $$3'} | tr -d '"''')
AWS_ACCESS_KEY_ID 	  := $(shell grep aws_access_key_id terraform/inputs.hcl \
					      | awk '{print $$3}' | tr -d '"''')
AWS_SECRET_ACCESS_KEY := $(shell grep aws_secret_access_key terraform/inputs.hcl \
						  | awk '{print $$3}' | tr -d '"'')

# General process:
# testenv(mac or linux) ▶️ build program ▶️ deploy infra ▶️ provision server ▶️ cleanup 
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	TARGET = check-mac build apply deploy clean
else ifeq ($(UNAME), Linux)
	TARGET = check-linux build apply deploy clean
else
	TARGET = wrong-platform
endif

# Service targets (will never be called directly)
logo:
	clear
	head -n 14 README.md | tail -n 13
	echo

notice:
	echo "🔐 Loaded AWS access key: $(AWS_ACCESS_KEY_ID)"
	echo "🔑 Loaded AWS secret key: 🙉🙊🙈"
	echo "👨 Loaded AWS profile: $(AWS_PROFILE)"
	echo "📍 Loaded AWS region: $(AWS_REGION)"
	echo
	echo "➤ Run \"make config\" to configure AWS account"
	echo "(or directly edit file terraform/inputs.hcl)"
	echo

check-mac: logo
	echo "🍏 Checking env requirements in mac ..."
	command -v docker > /dev/null 2>&1 || \
		(echo "❌ Error: Docker required."; \
		 echo "Visit https://docs.docker.com/desktop/mac/install/"; \
		 exit 1)
	echo "✅ OK..."

check-linux: logo
	echo "🐧 Checking linux requirements..."
	command -v docker > /dev/null 2>&1 || \
		(echo "❌ Error: Docker required."; \
		 echo "Visit https://docs.docker.com/engine/install/"; \
		 exit 1)
	echo "✅ OK..."

wrong-platform: logo
	echo "❌ Error: Wrong platform"

# 🗄️ Common targets
install: $(TARGET) ## Install Holtzman-effect
config: logo ## Configure AWS account credentials
	read -p "🔐 Enter AWS Access Key ID (press \"Enter\" to skip): " AWS_ACCESS_KEY_ID ;\
		if [ ! -z $$AWS_ACCESS_KEY_ID ]; then \
			sed -i.bak s/aws_access_key_id.*/aws_access_key_id\ =\ \"$$AWS_ACCESS_KEY_ID\"/g terraform/inputs.hcl; \
			echo AWS_ACCESS_KEY_ID now is $$AWS_ACCESS_KEY_ID; \
		else \
			echo AWS_ACCESS_KEY_ID unchanged; \
		fi ;\
		echo

	read -p "🔐 Enter AWS Secret Access Key (press \"Enter\" to skip): " AWS_SECRET_ACCESS_KEY ;\
		if [ ! -z $$AWS_SECRET_ACCESS_KEY_ID ]; then \
			sed -i.bak s/aws_secret_access_key.*/aws_secret_access_key\ =\ \"$$AWS_SECRET_ACCESS_KEY\"/g terraform/inputs.hcl; \
			echo AWS_SECRET_ACCESS_KEY now is $$AWS_SECRET_ACCESS_KEY; \
		else \
			echo AWS_SECRET_ACCESS_KEY unchanged; \
		fi ;\
		echo

	read -p "👨 Enter AWS profile (press \"Enter\" to skip): " AWS_PROFILE ;\
		if [ ! -z $$AWS_PROFILE ]; then \
			sed -i.bak s/aws_profile.*/aws_profile\ =\ \"$$AWS_PROFILE\"/g terraform/inputs.hcl; \
			echo AWS_PROFILE now is $$AWS_PROFILE; \
		else \
			echo AWS_PROFILE unchanged; \
		fi ;\
		echo

	read -p "📍 Enter AWS region. Default eu-central-1 (press \"Enter\" to skip): " AWS_REGION ;\
		if [ ! -z $$AWS_REGION ]; then \
			sed -i.bak s/aws_region.*/aws_region\ =\ \"$$AWS_REGION\"/g terraform/inputs.hcl; \
			echo AWS_REGION now is $$AWS_REGION; \
		else \
			echo AWS_REGION unchanged; \
		fi ;\
		echo

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