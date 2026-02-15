locals {
  subject = coalesce(
    var.oidc_subject,
    "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}"
  )
}
