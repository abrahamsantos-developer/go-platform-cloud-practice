terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  // TODO: set the AWS region for your sandbox account.
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

// TODO: add safe first resources here, for example:
// - one S3 bucket with a lifecycle rule
// - one ECR repository for the goose image
// - one small EC2 instance only if you have verified free-tier eligibility
//
// Avoid starting with:
// - EKS
// - NAT gateways
// - multi-AZ databases
// - anything you cannot destroy confidently the same day
