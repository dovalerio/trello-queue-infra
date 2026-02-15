locals {
  name_prefix = "${var.project}-${var.environment}"

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  lambda_env = merge(
    {
      SQS_QUEUE_URL = module.sqs.queue_url
    },
    var.lambda_environment_variables
  )
}
