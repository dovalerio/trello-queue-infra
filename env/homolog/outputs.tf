output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "lambda_function_name" {
  value = module.lambda.function_name
}

output "api_endpoint" {
  value = module.api_gateway.api_endpoint
}

output "github_actions_role_arn" {
  value = module.iam.role_arn
}

output "oidc_provider_arn" {
  value = module.iam.oidc_provider_arn
}
