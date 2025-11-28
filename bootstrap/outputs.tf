output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.state_bucket.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.state_bucket.arn
}

output "state_bucket_region" {
  description = "Region where the state bucket is located"
  value       = aws_s3_bucket.state_bucket.region
}
