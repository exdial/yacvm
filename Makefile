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
	TARGET = check-mac build deploy provision clean
else ifeq ($(UNAME), Linux)
	TARGET = check-linux build deploy provision clean
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
	echo "❌ Error: Wrong platform (only Mac and Linux supported)"
	echo

# 🗄️ Common targets
install: $(TARGET) ## 🚀 Install Holtzman-effect
uninstall: logo destroy clean ## 🗑️  Destroy deployed infrastructure
config: logo ## 🔐 Configure AWS account credentials
	read -p "🔐 Enter AWS Access Key ID (press \"Enter\" to skip): " AWS_ACCESS_KEY_ID ;\
		if [ ! -z $$AWS_ACCESS_KEY_ID ]; then \
			sed -i.bak s/aws_access_key_id.*/aws_access_key_id\ =\ \"$$AWS_ACCESS_KEY_ID\"/g terraform/inputs.hcl; \
			echo AWS_ACCESS_KEY_ID now is $$AWS_ACCESS_KEY_ID; \
		else \
			echo AWS_ACCESS_KEY_ID unchanged; \
		fi ;\
		echo

	read -p "🔑 Enter AWS Secret Access Key (press \"Enter\" to skip): " AWS_SECRET_ACCESS_KEY ;\
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

build: logo
	echo "🏗  Building the Docker image..."
	echo
	docker build -t holtzman-effect . -f Dockerfile
	echo "✅ OK..."
	echo

dry-run: logo ## 🖇️  Dry run of infrastructure deployment (no real changes)
	echo "🏝  Running terraform plan..."
	echo
	docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		holtzman-effect sh -c "cd terraform && terragrunt plan"
	echo "✅ OK..."
	echo

deploy: logo ## 💡 Deploy the infrastructure
	echo "🏝  Running terraform apply..."
	echo
	docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		holtzman-effect sh -c "cd terraform && terragrunt apply"
	echo "✅ OK..."
	echo

ping: logo ## 📡 Check server reachability
	echo "📡  Running Ansible ping..."
	echo
	if [ -f _output/inventory ]; then \
		docker run --rm -v `pwd`:/code holtzman-effect sh -c \
			"cd ansible && ansible all -m ping"; \
	else \
		echo "❌ Error: ansible inventory not found"; \
		echo "Please make sure you already have a deployed server,"; \
		echo "or perform a new deployment with \`make install\`."; \
		exit 1; \
	fi ;\
	echo

provision: logo
	echo "🏝 Running Ansible playbook..."
	echo
	docker run --rm -v `pwd`:/code holtzman-effect sh -c \
		"cd ansible && ansible-playbook site.yml"
	echo "✅ OK..."
	echo

destroy: logo
	echo "🗑️  Destroying deployed infrastructure..."
	echo
	docker run --rm -v `pwd`:/code -v $$HOME/.aws:/home/user/.aws \
		holtzman-effect sh -c "cd terraform && terragrunt destroy"
	echo "✅ OK..."
	echo

clean: logo
	echo "🧹 Cleanup..."
	echo
	rm -f ansible/ubuntu-bionic-18.04-cloudimg-console.log \
		terraform/_setup.tf terraform/_backend.tf terraform/inputs.hcl.bak \
		terraform/terraform.tfstate terraform/terraform.tfstate.backup \
		terraform/.terraform.lock.hcl
	rm -rf terraform/.terraform
	echo "✅ OK..."
	echo

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: logo notice
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: *