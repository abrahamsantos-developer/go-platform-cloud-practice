variable "aws_region" {
  type        = string
  description = "AWS region for the sandbox"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Short project prefix for AWS resource names"
  default     = "goose-practice"
}

variable "environment" {
  type        = string
  description = "Environment label for tagging"
  default     = "sandbox"
}
