module "trello_webhook_stack" {
  source = "../../modules/trello_webhook_stack"

  environment                  = "prod"
  aws_region                   = var.aws_region
  lambda_package_path          = var.lambda_package_path
  lambda_environment_variables = var.lambda_environment_variables
  lambda_runtime               = "nodejs18.x"
  lambda_timeout               = 60
  lambda_memory_size           = 256
  sqs_batch_size               = 10
  api_stage_name               = "v1"
}
