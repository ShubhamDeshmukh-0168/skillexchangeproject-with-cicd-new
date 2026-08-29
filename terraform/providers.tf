terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Bucket/key/region are supplied at `terraform init` time via
  # -backend-config flags (see .github/workflows/full-deploy.yml), which
  # creates the bucket itself on first run — nothing to fill in here.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
