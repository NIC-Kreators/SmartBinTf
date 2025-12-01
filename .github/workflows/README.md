# GitHub Actions Terraform Deployment

This workflow automates the deployment of Terraform infrastructure for the SmartBin project.

## Workflow Overview

The pipeline deploys infrastructure in the following order:

1. **Bootstrap** - S3 backend and foundational resources
2. **Global** - Cross-environment resources (IAM roles, etc.)
3. **Root** - Workload infrastructure

## Optimization Features

- **Provider Caching**: AWS provider is downloaded once and cached across all modules
- **Sequential Deployment**: Modules are deployed in dependency order
- **Conditional Apply**: Only applies changes on `main` branch pushes

## Behavior

### On `main` branch push

- Runs `terraform plan` for all modules
- Runs `terraform apply` for all modules (auto-approved)
- Deploys to Production environment

### On feature branch / PR

- Runs `terraform plan` for all modules
- **Does NOT apply** any changes
- Use this to validate changes locally before merging

## Prerequisites

### 1. AWS Account ID Secret

Add your AWS Account ID as a repository secret:

- Go to: Repository Settings → Secrets and variables → Actions
- Create secret: `AWS_ACCOUNT_ID` with your AWS account ID

### 2. GitHub OIDC Configuration

The workflow uses OIDC to authenticate with AWS (no access keys needed).
The IAM role `SmartBinGithubActionsRole` should already be created by the `global` module.

Ensure the role has:

- Trust policy allowing GitHub Actions OIDC
- Permissions to manage Terraform resources

### 3. S3 Backend

The S3 bucket `smart-bin.eu-central-1.tf` must exist before running the workflow.
This is created by the bootstrap module on first manual run.

## First-Time Setup

1. **Manual Bootstrap**: Run bootstrap module locally first:

   ```bash
   cd bootstrap
   terraform init
   terraform apply
   ```

2. **Manual Global**: Run global module to create GitHub Actions IAM role:

   ```bash
   cd global
   terraform init
   terraform apply
   ```

3. **Configure Secret**: Add `AWS_ACCOUNT_ID` to GitHub repository secrets

4. **Push to main**: The workflow will now handle subsequent deployments

## Local Development

For feature branches, run Terraform locally:

```bash
# Plan changes
cd bootstrap  # or global, or root
terraform init
terraform plan

# Apply if needed (be careful!)
terraform apply
```

## Enabling Root Module

When ready to deploy root infrastructure, uncomment the Root Module section in the workflow file.

## Troubleshooting

- **Provider download slow**: The cache should speed this up after first run
- **Authentication failed**: Check AWS_ACCOUNT_ID secret and IAM role trust policy
- **State lock errors**: Ensure S3 bucket has locking enabled
