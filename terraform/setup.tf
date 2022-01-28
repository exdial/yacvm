terraform {
  required_version = "1.0.11"

  backend "s3" {
    bucket = "terraform"
    key    = ""
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "rfc4251"

  skip_credentials_validation = true
  skip_get_ec2_platforms      = true
  skip_region_validation      = true
  skip_metadata_api_check     = true
}
