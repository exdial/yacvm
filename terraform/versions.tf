# Required providers and their versions
terraform {
  required_version = "1.3.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.2.1"
    }
  }
}