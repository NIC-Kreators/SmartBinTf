# Bootstrap Module

This module sets up the foundational infrastructure for managing Terraform state in AWS. It creates an S3 bucket configured with versioning and encryption to store Terraform state files securely.

## Purpose

The bootstrap module is designed to be run once at the beginning of your infrastructure setup. It creates the remote backend infrastructure that other Terraform configurations will use to store their state files.

## What It Creates

- **S3 Bucket**: A dedicated bucket for storing Terraform state files
  - Versioning enabled for state file history
  - Server-side encryption (AES256) for security
  - Public access blocked for security
  - Tagged with project metadata

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version compatible with AWS provider ~> 6.0)
- AWS permissions to create S3 buckets

## Configuration

### Variables

- `aws_region` (default: `eu-central-1`): AWS region where resources will be created
- `s3_state_bucket_name` (required): Name for the S3 bucket that will store Terraform state

### Current Configuration

The `terraform.tfvars` file contains:

```tf
aws_region = "eu-central-1"
s3_state_bucket_name = "smart-bin.eu-central-1.tf"
```

## Usage

### Initial Bootstrap (First Time Only)

If the S3 bucket doesn't exist yet:

1. Navigate to the bootstrap directory:

```bash
cd bootstrap
```

2. Temporarily comment out the backend block in `backend.tf` (don't commit this change)

3. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

4. Uncomment the backend in `backend.tf` and migrate state:

```bash
terraform init -migrate-state
```

5. Confirm the migration when prompted

### Subsequent Runs (CI/CD or Updates)

Once the bucket exists, the backend configuration is active:

```bash
cd bootstrap
terraform init
terraform plan
terraform apply
```

### Important Notes

- **Run this module first**: This must be executed before any other Terraform modules that depend on remote state storage
- **Backend in git**: Keep the backend configuration uncommented in version control for CI/CD pipelines
- **One-time setup**: The initial bootstrap process only needs to be done once per project/environment
- **S3 native locking**: Uses S3's built-in locking feature (requires Terraform 1.9+), no DynamoDB table needed

## Backend Configuration

The module uses S3 backend with the following settings:

- Bucket: `smart-bin.eu-central-1.tf`
- Key: `bootstrap/terraform.tfstate`
- Region: `eu-central-1`
- Encryption: Enabled
- Locking: Enabled via lockfile

## Outputs

- `state_bucket_name`: Name of the created S3 bucket
- `state_bucket_arn`: ARN of the S3 bucket
- `state_bucket_region`: AWS region where the bucket is located

These outputs can be used by other modules to reference the state bucket.

## Maintenance

### Viewing State History

Since versioning is enabled, you can view previous versions of the state file in the S3 console or via AWS CLI.

### Destroying Resources

To tear down the bootstrap infrastructure:

```bash
terraform destroy
```

**Warning**: Only destroy this infrastructure if you're certain no other Terraform configurations are using this bucket for state storage.
