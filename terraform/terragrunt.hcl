# Terragrunt.hcl is the main configuration file for the Terragrunt,
# which is a thin wrapper, that provides extra tools for keeping Terraform
# configurations DRY, and managing remote state.

# Load profile and region variables from inputs.hcl
# and define fallback variables in case the former are missing
locals {
  # Top level variables
  external_vars = read_terragrunt_config("inputs.hcl")

  aws_profile = local.external_vars.locals.aws_profile
  aws_region  = local.external_vars.locals.aws_region

  aws_profile_fallback = local.aws_profile == "" ? "default" : local.aws_profile
  aws_region_fallback  = local.aws_region == "" ? "us-east-1" : local.aws_region

  output_dir = local.external_vars.locals.output_dir

  project_name = "yacvm"
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

# Define generate block for Terraform backend configuration,
# where the Terraform stores its state
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "local" {
    path = "${local.output_dir}/terraform.tfstate"
  }
}
  EOF
}

# Define generate block for important configurations
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
# Provider configuration
provider "aws" {
  profile  = "${local.aws_profile_fallback}"
  region   = "${local.aws_region_fallback}"
  insecure = false
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}
  EOF
}

# Define generate block for Terraform variables
generate "variables" {
  path      = "variables.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
# The directory will contain ssh keys for the EC2 instance, OpenVPN keys,
# Ansible inventory file and terraform state file.
variable "output_dir" {
  type        = string
  description = "Directory for artifacts"
  default     = "${local.output_dir}"
}
variable "name" {
  type        = string
  description = "Project name"
  default     = "${local.project_name}"
}
  EOF
}

inputs = merge(local.external_vars.locals)
