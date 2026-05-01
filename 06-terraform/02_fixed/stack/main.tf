terraform {
  required_version = ">= 1.5.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = var.aws_region
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    dynamodb = var.endpoint
    s3       = var.endpoint
    sts      = var.endpoint
  }
}

resource "time_sleep" "hold" {
  create_duration = var.hold_duration
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name

  depends_on = [time_sleep.hold]
}

resource "aws_dynamodb_table" "app_table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  depends_on = [time_sleep.hold]
}
