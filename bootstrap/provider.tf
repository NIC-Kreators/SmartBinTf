provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      CreatedWith = "Terraform",
      ProjectName = var.project_name,
      Environment = var.environment
    }
  }
}
