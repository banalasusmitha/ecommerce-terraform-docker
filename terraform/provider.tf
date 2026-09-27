# Which Terraform version and which provider (plugin) we need
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider: uses the credentials you set with "aws configure"
provider "aws" {
  region = var.aws_region

  # These tags are added to every AWS resource this project creates
  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
    }
  }
}
