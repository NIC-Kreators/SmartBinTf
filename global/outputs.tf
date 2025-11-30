output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "ARN of the IAM role created for GitHub Actions"
}

output "github_actions_role_name" {
  value       = aws_iam_role.github_actions_role.name
  description = "Name of the IAM role created for GitHub Actions"
}

output "github_actions_role_id" {
  value       = aws_iam_role.github_actions_role.id
  description = "ID of the IAM role created for GitHub Actions"
}

output "github_actions_inline_policy_name" {
  value       = aws_iam_role_policy.github_actions_inline_policy.name
  description = "Name of the inline policy attached to the GitHub Actions role"
}

output "aws_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID where resources are deployed"
}

output "oidc_provider_arn" {
  value       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.github_actions_token_host}"
  description = "ARN of the GitHub OIDC provider"
}
