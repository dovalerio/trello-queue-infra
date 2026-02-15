output "sqs_queue_url" {
  description = "URL of the production SQS queue for Trello webhooks"
  value       = module.trello_webhook_stack.sqs_queue_url
}

output "sqs_queue_arn" {
  description = "ARN of the production SQS queue for Trello webhooks"
  value       = module.trello_webhook_stack.sqs_queue_arn
}

output "dlq_url" {
  description = "URL of the production Dead Letter Queue"
  value       = module.trello_webhook_stack.dlq_url
}

output "lambda_function_name" {
  description = "Name of the production Lambda function"
  value       = module.trello_webhook_stack.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the production Lambda function"
  value       = module.trello_webhook_stack.lambda_function_arn
}

output "api_gateway_url" {
  description = "URL of the production API Gateway endpoint"
  value       = module.trello_webhook_stack.api_gateway_url
}

output "api_gateway_id" {
  description = "ID of the production API Gateway REST API"
  value       = module.trello_webhook_stack.api_gateway_id
}
