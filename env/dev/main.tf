module "s3" {
  source        = "../../modules/s3"
  bucket_name   = coalesce(var.artifact_bucket_name, "${local.name_prefix}-artifacts")
  force_destroy = var.s3_force_destroy
  tags          = local.tags
}

module "sqs" {
  source                     = "../../modules/sqs"
  queue_name                 = coalesce(var.sqs_queue_name, "${local.name_prefix}-queue")
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  tags                       = local.tags
}

module "lambda" {
  source                  = "../../modules/lambda"
  function_name           = coalesce(var.lambda_function_name, "${local.name_prefix}-webhook")
  handler                 = var.lambda_handler
  runtime                 = var.lambda_runtime
  timeout                 = var.lambda_timeout
  memory_size             = var.lambda_memory_size
  artifact_bucket         = module.s3.bucket_name
  artifact_key            = var.lambda_artifact_key
  artifact_object_version = var.lambda_artifact_object_version
  environment_variables   = local.lambda_env
  sqs_queue_arn           = module.sqs.queue_arn
  tags                    = local.tags
}

module "api_gateway" {
  source               = "../../modules/api-gateway"
  api_name             = coalesce(var.api_name, "${local.name_prefix}-api")
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
  tags                 = local.tags
}

module "iam" {
  source                   = "../../modules/iam"

  github_repo              = var.github_repo
  github_branch            = var.github_branch
  github_actions_role_name = coalesce(var.github_actions_role_name, "${local.name_prefix}-github-actions")
  artifact_bucket_arn      = module.s3.bucket_arn
  additional_policy_arns   = var.github_actions_additional_policy_arns
  tags                     = local.tags
}
