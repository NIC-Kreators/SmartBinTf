variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources in"
}

variable "github_actions_role_name" {
  type        = string
  description = "Name of the IAM role for GitHub Actions"
}

variable "github_org" {
  type        = string
  description = "GitHub organization name"
}

variable "github_actions_token_host" {
  type        = string
  default     = "token.actions.githubusercontent.com"
  description = "GitHub URL for OIDC token actions"
}

variable "project_name" {
  type = string
  description = "The project name"
}

variable "environment" {
  type = string
  description = "The current project's environemnt"
}