terraform {
  backend "s3" {
    bucket       = "smart-bin.eu-central-1.tf"
    key          = "infrastructure/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
