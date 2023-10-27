# Set the Makefile default goal
.DEFAULT_GOAL := help

# Define target .SILENT: to disable printing by default
# Use the "DEBUG=1" flag to make process more talkative
# example: "make DEBUG=1 help"
ifndef DEBUG
.SILENT:
endif

# Load variables from terraform/inputs.hcl to show them in the main menu
AWS_PROFILE := $(shell grep aws_profile terraform/inputs.hcl | cut -d '"' -f2)
AWS_REGION := $(shell grep aws_region terraform/inputs.hcl | cut -d '"' -f2)
AWS_ACCESS := $(shell grep aws_access terraform/inputs.hcl | cut -d '"' -f2)
AWS_USE_SPOT := $(shell grep aws_use_spot terraform/inputs.hcl | cut -d '"' -f2)

# Detect OS
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
    TARGET = check-mac build deploy provision clean
else ifeq ($(UNAME), Linux)
    TARGET = check-linux build deploy provision clean
else
    TARGET = wrong-platform
endif

# Service targets (will never be called directly)
logo:
	clear
	head -n 9 README.md | tail -n 8
	echo

notice:
	[ "${AWS_PROFILE}" ] && echo "🪪 AWS profile in use: $(AWS_PROFILE)" || true
	[ "${AWS_REGION}" ] && echo "📍 AWS region in use: $(AWS_REGION)" || true
	[ "${AWS_ACCESS}" ] && echo "🔑 AWS access key id in use: $(AWS_ACCESS)" || true
	[ "${AWS_USE_SPOT}" == true ] && echo "☁️  AWS capacity type: spot" || echo "☁️  AWS capacity type: on-demand" 
	echo
	echo "➤ Run \"make config\" to configure AWS account"
	echo "(or directly edit file terraform/inputs.hcl)"
	echo

check-mac: logo
	echo "🍏 Checking env requirements in mac ..."
	echo
	command -v docker &>/dev/null || \
		(echo "❌ Error: Docker required"; \
		 echo "Visit https://docs.docker.com/desktop/mac/install/"; \
		 echo; \
		 exit 1)
	docker info &>/dev/null || \
		(echo "❌ Error: Docker Desktop is not running"; \
		 echo; \
		 exit 1)
	echo "✅ OK..."
	echo

check-linux: logo
	echo "🐧 Checking linux env requirements..."
	echo
	command -v docker &>/dev/null || \
		(echo "❌ Error: Docker required"; \
		 echo "Visit https://docs.docker.com/engine/install/"; \
		 echo; \
		 exit 1)
	docker info &>/dev/null || \
		(echo "❌ Error: Docker daemon is not running"; \
		 exit 1)
	echo "✅ OK..."
	echo

wrong-platform: logo
	echo "❌ Error: Wrong platform (only Mac and Linux are supported)"
	echo

# 🗄️ Common targets
install: $(TARGET) ## 🚀 Install YACVM
uninstall: logo destroy clean ## 🗑️  Destroy deployed infrastructure
config: logo ## 🔐 Configure AWS account credentials
	read -p "🪪 Enter AWS Profile (press \"Enter\" to skip): " AWS_PROFILE ;\
		if [ ! -z $$AWS_PROFILE ]; then \
			sed -i.bak s/aws_profile.*/aws_profile\ =\ \"$$AWS_PROFILE\"/g terraform/inputs.hcl; \
			echo AWS Profile now is $$AWS_PROFILE; \
		else \
			echo AWS Profile unchanged; \
		fi ;\
		echo

	read -p "📍 Enter AWS Region. Default us-east-1 (press \"Enter\" to skip): " AWS_REGION ;\
		if [ ! -z $$AWS_REGION ]; then \
			sed -i.bak s/aws_region.*/aws_region\ =\ \"$$AWS_REGION\"/g terraform/inputs.hcl; \
			echo AWS Region now is $$AWS_REGION; \
		else \
			echo AWS Region unchanged; \
		fi ;\
		echo

	read -p "🔑 Enter AWS Access Key ID (press \"Enter\" to skip): " AWS_ACCESS ;\
		if [ ! -z $$AWS_ACCESS ]; then \
			sed -i.bak s/aws_access_key_id.*/aws_access_key_id\ =\ \"$$AWS_ACCESS\"/g terraform/inputs.hcl; \
			echo AWS Access Key ID now is $$AWS_ACCESS; \
		else \
			echo AWS Access Key ID unchanged; \
		fi ;\
		echo

	read -p "🔐 Enter AWS Secret Access Key (press \"Enter\" to skip): " AWS_SECRET ;\
		if [ ! -z $$AWS_SECRET ]; then \
			sed -i.bak s/aws_secret_access_key.*/aws_secret_access_key\ =\ \"$$AWS_SECRET\"/g terraform/inputs.hcl; \
			echo AWS Secret Access Key now is $$AWS_SECRET; \
		else \
			echo AWS Secret Access Key unchanged; \
		fi ;\
		echo

	read -p "☁️  Would you like to use AWS spot instances [true|false]? (press \"Enter\" to skip): " AWS_USE_SPOT ;\
		if [ ! -z $$AWS_USE_SPOT ]; then \
			sed -i.bak s/aws_use_spot.*/aws_use_spot\ =\ \"$$AWS_USE_SPOT\"/g terraform/inputs.hcl; \
		else \
			echo AWS capacity type unchanged; \
		fi ;\
		echo

build: logo
	echo "🏗  Building Docker image..."
	echo
	docker build -t yacvm . -f Dockerfile
	echo "✅ OK..."
	echo

dry-run: logo ## 🖇️  Dry run of infrastructure deployment (no real changes)
	echo "🏝  Running terraform plan..."
	echo
	docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		yacvm sh -c "cd terraform && terragrunt plan"
	echo "✅ OK..."
	echo

deploy: logo ## 💡 (re)Deploy the infrastructure
	echo "🏝  Running terraform apply..."
	echo
	docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		yacvm sh -c "cd terraform && terragrunt apply"
	echo "✅ OK..."
	echo

ping: logo ## 📡 Check server reachability
	echo "📡  Running Ansible ping..."
	echo
	if [ -f artifacts/inventory ]; then \
		docker run --rm -v `pwd`:/code yacvm sh -c \
			"cd ansible && ansible all -m ping"; \
	else \
		echo "❌ Error: ansible inventory not found"; \
		echo "Please make sure you already have a deployed server,"; \
		echo "or perform a new deployment with make install."; \
		exit 1; \
	fi ;\
	echo

provision: logo
	echo "🏝  Running Ansible playbook..."
	echo
	docker run --rm -v `pwd`:/code yacvm sh -c \
		"cd ansible && ansible-playbook main.yml"
	echo "✅ OK..."
	echo

destroy: logo
	echo "🗑️  Destroying deployed infrastructure..."
	echo
	docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		yacvm sh -c "cd terraform && terragrunt destroy"
	echo "✅ OK..."
	echo

clean: logo
	echo "🧹 Cleanup..."
	echo
	rm -f ansible/ubuntu-bionic-18.04-cloudimg-console.log \
		terraform/_setup.tf terraform/_backend.tf terraform/inputs.hcl.bak \
		terraform/terraform.tfstate.backup
	echo "✅ OK..."
	echo

ifeq (vpnconfig,$(firstword $(MAKECMDGOALS)))
    OVPN_NAME := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    ifndef OVPN_NAME
        $(error ❌ VPN config name is not defined. Try "make vpnconfig elonmusk")
    endif
    $(eval $(OVPN_NAME):;@:)
endif

vpnconfig: ## 🪪  Issue VPN config
	echo "🪪 Generating VPN configuration..."
		docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		yacvm sh -c \
			"cd ansible && ansible-playbook main.yml -t client -e clientname=$(OVPN_NAME)"
	echo "✅ OK..."
	echo

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: logo notice
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: * vpnconfig
