# Terragrunt.hcl is the main configuration file for the Terragrunt,
# which is a thin wrapper, that provides extra tools for keeping Terraform
# configurations DRY, and managing remote state.

# Load profile and region variables from inputs.hcl
# and define fallback variables in case the former are missing
locals {
  profile_vars = read_terragrunt_config("inputs.hcl")
  region_vars  = read_terragrunt_config("inputs.hcl")

  aws_profile = local.profile_vars.locals.aws_profile
  aws_region  = local.region_vars.locals.aws_region

  aws_profile_fallback = local.aws_profile == "" ? "default" : local.aws_profile
  aws_region_fallback  = local.aws_region == "" ? "us-east-1" : local.aws_region

}

# Define default Terraform behavior
terraform {
  # Run `terraform init` every time when `terraform apply`
  # or `terraform plan` is called
  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute  = ["terraform", "init"]
  }

  # Force Terraform to auto approve "apply" and "destroy" commands
  extra_arguments "auto_approve" {
    commands = [
      "apply",
      "destroy"
    ]

    arguments = [
      "-auto-approve"
    ]
  }
}

# Define generate block for important configurations
generate "setup" {
  path      = "_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_version = "1.1.0"

      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
        }
        tls = {
          source = "hashicorp/tls"
          version = "~> 4.0.4"
        }
        local = {
          source = "hashicorp/local"
          version = "~> 2.2.3"
        }
        random = {
          source = "hashicorp/random"
          version = "~> 3.4.3"
        }
        http = {
          source = "hashicorp/http"
          version = "~> 3.2.1"
        }
      }
    }

    provider "aws" {
      profile = "${local.aws_profile_fallback}"
      region = "${local.aws_region_fallback}"
      insecure = false
      default_tags {
        tags = {
          Terraform = "true"
        }
      }
    }
  EOF
}

inputs = merge(
  local.profile_vars.locals,
  local.region_vars.locals
)
