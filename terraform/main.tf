module "github_actions_role" {
  source = "./module/github_actions_iam_role"
  github_owner_name = "sun-yryr"
  github_repository_name = "agqr-program-guide"
  attach_arns = [ aws_iam_policy.read_sts.arn ]
}

resource "aws_iam_policy" "read_sts" {
  name = "read_sts_policy"
  description = "read_sts_policy"
  policy = data.aws_iam_policy_document.sts.json
}

data "aws_iam_policy_document" "sts" {
  statement {
    actions = [ "sts:GetCallerIdentity" ]
    resources = [ "*" ]
  }
}
