data "aws_ecr_repository" "api" {
  name = aws_ecr_repository.smart_bin_api_ecr_repo.name
}