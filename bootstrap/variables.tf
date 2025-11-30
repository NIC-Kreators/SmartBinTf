variable "aws_region" {
  type = string
  default = "eu-central-1"
  description = "AWS region to deploy resources in"
}

variable "s3_state_bucket_name" {
  type = string
  description = "Name of the S3 bucket used for Terraform state"
}

variable "project_name" {
  type = string
  description = "The project name"
}

variable "environment" {
  type = string
  description = "The current project's environemnt"
}