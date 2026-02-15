# Provider OIDC do GitHub (existente na conta)
data "aws_iam_openid_connect_provider" "github" {
  url = var.oidc_provider_url
}

# Documento de confiança para o GitHub Actions
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [var.oidc_audience]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.subject]
    }
  }
}

# Role assumida pelo GitHub Actions
resource "aws_iam_role" "github_actions" {
  name               = var.github_actions_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

# Permissão para o bucket de artefatos
data "aws_iam_policy_document" "artifact_bucket" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      var.artifact_bucket_arn,
      "${var.artifact_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "artifact_bucket" {
  name   = "artifact-bucket-access"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.artifact_bucket.json
}

# Policies adicionais opcionais
resource "aws_iam_role_policy_attachment" "additional" {
  for_each   = toset(var.additional_policy_arns)
  role       = aws_iam_role.github_actions.name
  policy_arn = each.value
}
