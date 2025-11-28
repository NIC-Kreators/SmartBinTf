variable "aws_region" {
  type = string
  default = "eu-central-1"
  description = "AWS region to deploy resources in"
}

variable "s3_state_bucket_name" {
  type = string
  description = "Name of the S3 bucket used for Terraform state"
}