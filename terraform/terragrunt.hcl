locals {
  profile_vars = read_terragrunt_config("inputs.hcl")
  region_vars = read_terragrunt_config("inputs.hcl")

  aws_profile = local.profile_vars.locals.aws_profile
  aws_region  = local.region_vars.locals.aws_region

  aws_profile_fallback = local.aws_profile == "" ? "default" : local.aws_profile
  aws_region_fallback = local.aws_region == "" ? "us-east-1" : local.aws_region

}

terraform {
  # Run `terraform init` every time `terraform apply`
  # or `terraform plan` is called
  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute  = ["terraform", "init"]
  }
  
  # Remove generated files after terragrunt has finished
  after_hook "after_hook" {
    commands     = ["apply", "plan"]
    execute      = ["rm", "_setup.tf", "_backend.tf"]
    run_on_error = true
  }
  
  # Force Terraform to auto approve dangerous commands
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

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "local"
  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {}

}

generate "setup" {
  path = "_setup.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
    terraform {
      required_version = "1.1.0"

      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
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
