data "aws_iam_policy_document" "github_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.github_actions_token_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${var.github_actions_token_host}:sub"
      values   = ["repo:${var.github_org}/*:*"]
    }
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name               = var.github_actions_role_name
  assume_role_policy = data.aws_iam_policy_document.github_role_policy.json

  tags = {
    CreatedWith = "Terraform"
    ProjectName = "SmartBin"
  }
}

# Custom inline policy with consolidated permissions
resource "aws_iam_role_policy" "github_actions_inline_policy" {
  name = "${var.github_actions_role_name}-inline-policy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "ecs:*",
          "ecr:*",
          "elasticloadbalancing:*",
          "rds:*",
          "cloudwatch:*",
          "logs:*",
          "redshift:*",
          "sagemaker:*",
          "iot:*",
          "route53:*",
          "s3:*",
          "dynamodb:*",
          "iam:*",
          "vpc:*"
        ]
        Resource = "*"
      }
    ]
  })
}
