# Global Infrastructure

This Terraform configuration manages global AWS resources for the SmartBin project, including IAM roles for GitHub Actions OIDC authentication.

## Resources

- **IAM Role for GitHub Actions**: Enables GitHub Actions workflows to authenticate with AWS using OIDC (OpenID Connect) without storing long-lived credentials
- **Inline IAM Policy**: Grants comprehensive permissions for deploying and managing SmartBin infrastructure

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0
3. S3 backend initialized (see `bootstrap` folder)
4. GitHub OIDC provider configured in AWS IAM

## Configuration

Update `terraform.tfvars` with your values:

```hcl
aws_region                = "eu-central-1"
github_actions_role_name  = "SmartBinGithubActionsRole"
github_org                = "your-github-org"
github_actions_token_host = "token.actions.githubusercontent.com"
```

## Usage

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply

# View outputs
terraform output
```

## Outputs

- `github_actions_role_arn`: ARN to use in GitHub Actions workflows
- `github_actions_role_name`: Role name for reference
- `aws_account_id`: AWS account where resources are deployed
- `oidc_provider_arn`: GitHub OIDC provider ARN

## GitHub Actions Integration

Use the role ARN in your GitHub Actions workflow:

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: eu-central-1
```

## Permissions

The inline policy grants full access to:

- EC2, ECS, ECR
- Elastic Load Balancing
- RDS/DocumentDB
- CloudWatch & Logs
- Redshift, SageMaker
- IoT, Route53
- S3, DynamoDB
- IAM, VPC

## Notes

- Uses inline policy to avoid the 10 managed policies per role AWS limit
- State stored in S3 backend at `global/terraform.tfstate`
- OIDC trust policy restricts access to repositories in the specified GitHub organization
