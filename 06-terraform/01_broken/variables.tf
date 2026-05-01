variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "endpoint" {
  type    = string
  default = "http://localhost:4566"
}

variable "bucket_name" {
  type    = string
  default = "goose-broken-app-state"
}

variable "table_name" {
  type    = string
  default = "goose-broken-app-table"
}

variable "hold_duration" {
  type    = string
  default = "10s"
}
