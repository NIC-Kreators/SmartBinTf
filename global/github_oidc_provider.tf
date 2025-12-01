resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://${var.github_actions_token_host}"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}
