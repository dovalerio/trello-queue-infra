variable "github_actions_role_name" {
  type = string
}

variable "github_repo" {
  type    = string
  default = "dovalerio/trello-queue-publisher"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "artifact_bucket_arn" {
  type = string
}

variable "additional_policy_arns" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "oidc_provider_url" {
  type    = string
  default = "https://token.actions.githubusercontent.com"
}

variable "oidc_audience" {
  type    = string
  default = "sts.amazonaws.com"
}

variable "oidc_thumbprint" {
  type    = string
  default = "6938fd4d98bab03faadb97b34396831e3780aea1"
}

variable "oidc_subject" {
  type    = string
  default = null
}
