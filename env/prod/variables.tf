variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "trello"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "artifact_bucket_name" {
  type    = string
  default = null
}

variable "s3_force_destroy" {
  type    = bool
  default = false
}

variable "sqs_queue_name" {
  type    = string
  default = null
}

variable "sqs_visibility_timeout_seconds" {
  type    = number
  default = 30
}

variable "sqs_message_retention_seconds" {
  type    = number
  default = 345600
}

variable "lambda_function_name" {
  type    = string
  default = null
}

variable "lambda_runtime" {
  type    = string
}

variable "lambda_handler" {
  type    = string
}

variable "lambda_timeout" {
  type    = number
  default = 10
}

variable "lambda_memory_size" {
  type    = number
  default = 128
}

variable "lambda_artifact_key" {
  type = string
}

variable "lambda_artifact_object_version" {
  type    = string
  default = null
}

variable "lambda_environment_variables" {
  type    = map(string)
  default = {}
}

variable "api_name" {
  type    = string
  default = null
}

variable "github_actions_role_name" {
  type    = string
  default = null
}

variable "create_oidc_provider" {
  type    = bool
  default = true
}

variable "oidc_provider_arn" {
  type    = string
  default = null
}

variable "github_repo" {
  type    = string
  default = "dovalerio/trello-queue-publisher"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "github_actions_additional_policy_arns" {
  type    = list(string)
  default = []
}
