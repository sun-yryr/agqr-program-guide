# oidc provider
resource "aws_iam_role" "this" {
  name = "github_actions_role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.this_assume.json
}

data "aws_iam_policy_document" "this_assume" {
  statement {
    effect = "Allow"
    actions = [ "sts:AssumeRoleWithWebIdentity" ]
    principals {
      type = "Federated"
      identifiers = [ aws_iam_openid_connect_provider.github_oidc_provider.arn ]
    }
    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [ "repo:${var.github_owner_name}/${var.github_repository_name}:*" ]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [ "https://github.com/${var.github_owner_name}" ]
  thumbprint_list = [ "a031c46782e6e6c662c2c87c76da9aa62ccabd8e" ]
}

resource "aws_iam_role_policy_attachment" "attach" {
  count = length(var.attach_arns)
  role = aws_iam_role.this.name
  policy_arn = var.attach_arns[count.index]
}
