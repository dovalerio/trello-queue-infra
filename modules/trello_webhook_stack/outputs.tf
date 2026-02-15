output "sqs_queue_url" {
  description = "URL of the SQS queue for Trello webhooks"
  value       = aws_sqs_queue.trello_webhook_queue.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue for Trello webhooks"
  value       = aws_sqs_queue.trello_webhook_queue.arn
}

output "dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = aws_sqs_queue.trello_webhook_dlq.url
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = aws_sqs_queue.trello_webhook_dlq.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.trello_webhook_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.trello_webhook_processor.arn
}

output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = "${aws_api_gateway_stage.webhook_stage.invoke_url}/webhook"
}

output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.trello_webhook_api.id
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.webhook_stage.stage_name
}
