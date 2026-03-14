resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  # Required by AWS provider - these are the official GitHub thumbprints
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

resource "aws_iam_role" "github_actions_OIDC" {
  name = "github_actions_oidc"
  assume_role_policy = templatefile("${path.module}/${var.oidc_gha_role_path}", {
    "oidc_arn" : aws_iam_openid_connect_provider.github_actions.arn,
    "gh_oidc_sub" : var.gh_oidc_sub
  })
}

resource "aws_iam_policy" "github_actions_OIDC_policy" {
  name   = "github_actions_oidc_policy"
  policy = file("${path.module}/${var.oidc_gha_role_policy_path}")
}

resource "aws_iam_role_policy_attachment" "github_actions_OIDC_policy_attach" {
  role       = aws_iam_role.github_actions_OIDC.name
  policy_arn = aws_iam_policy.github_actions_OIDC_policy.arn
}
