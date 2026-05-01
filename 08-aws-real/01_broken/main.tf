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
  region = "us-east-1"
}

// TODO: add a bucket, instance, or registry here only after you estimate cost.
// TODO: do not apply this against AWS until you confirm your IAM identity with `aws sts get-caller-identity`.
