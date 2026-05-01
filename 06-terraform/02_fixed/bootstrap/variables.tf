variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "endpoint" {
  type    = string
  default = "http://localhost:4566"
}

variable "state_bucket_name" {
  type    = string
  default = "goose-terraform-state"
}

variable "lock_table_name" {
  type    = string
  default = "goose-terraform-locks"
}
