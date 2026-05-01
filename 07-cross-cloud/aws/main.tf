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
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name"
  default     = "goose-cross-cloud-aws-demo"
}

resource "aws_s3_bucket" "object_storage" {
  bucket = var.bucket_name

  tags = {
    Project     = "goose-cross-cloud"
    Environment = "demo"
    Provider    = "aws"
  }
}
