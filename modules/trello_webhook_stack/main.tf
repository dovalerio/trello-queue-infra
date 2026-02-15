# Trello Webhook Stack Module
# This module sets up the infrastructure for Trello webhooks

resource "aws_sqs_queue" "trello_webhook_queue" {
  name                       = "${var.environment}-trello-webhook-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 30

  tags = {
    Name        = "${var.environment}-trello-webhook-queue"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_sqs_queue" "trello_webhook_dlq" {
  name                      = "${var.environment}-trello-webhook-dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 0

  tags = {
    Name        = "${var.environment}-trello-webhook-dlq"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_lambda_function" "trello_webhook_processor" {
  function_name = "${var.environment}-trello-webhook-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  filename         = var.lambda_package_path
  source_code_hash = filebase64sha256(var.lambda_package_path)

  environment {
    variables = var.lambda_environment_variables
  }

  tags = {
    Name        = "${var.environment}-trello-webhook-processor"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-trello-webhook-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-trello-webhook-lambda-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "${var.environment}-lambda-sqs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:SendMessage"
        ]
        Resource = [
          aws_sqs_queue.trello_webhook_queue.arn,
          aws_sqs_queue.trello_webhook_dlq.arn
        ]
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.trello_webhook_queue.arn
  function_name    = aws_lambda_function.trello_webhook_processor.arn
  batch_size       = var.sqs_batch_size
  enabled          = true
}

resource "aws_api_gateway_rest_api" "trello_webhook_api" {
  name        = "${var.environment}-trello-webhook-api"
  description = "API Gateway for Trello webhooks"

  tags = {
    Name        = "${var.environment}-trello-webhook-api"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_api_gateway_resource" "webhook_resource" {
  rest_api_id = aws_api_gateway_rest_api.trello_webhook_api.id
  parent_id   = aws_api_gateway_rest_api.trello_webhook_api.root_resource_id
  path_part   = "webhook"
}

resource "aws_api_gateway_method" "webhook_post" {
  rest_api_id   = aws_api_gateway_rest_api.trello_webhook_api.id
  resource_id   = aws_api_gateway_resource.webhook_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sqs_integration" {
  rest_api_id             = aws_api_gateway_rest_api.trello_webhook_api.id
  resource_id             = aws_api_gateway_resource.webhook_resource.id
  http_method             = aws_api_gateway_method.webhook_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:sqs:path/${aws_sqs_queue.trello_webhook_queue.name}"
  credentials             = aws_iam_role.api_gateway_role.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}

resource "aws_api_gateway_method_response" "webhook_response_200" {
  rest_api_id = aws_api_gateway_rest_api.trello_webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.webhook_post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "sqs_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.trello_webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.webhook_post.http_method
  status_code = aws_api_gateway_method_response.webhook_response_200.status_code

  depends_on = [aws_api_gateway_integration.sqs_integration]
}

resource "aws_iam_role" "api_gateway_role" {
  name = "${var.environment}-trello-webhook-api-gateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-trello-webhook-api-gateway-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "api_gateway_sqs_policy" {
  name = "${var.environment}-api-gateway-sqs-policy"
  role = aws_iam_role.api_gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.trello_webhook_queue.arn
      }
    ]
  })
}

resource "aws_api_gateway_deployment" "webhook_deployment" {
  rest_api_id = aws_api_gateway_rest_api.trello_webhook_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.webhook_resource.id,
      aws_api_gateway_method.webhook_post.id,
      aws_api_gateway_integration.sqs_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.sqs_integration,
    aws_api_gateway_integration_response.sqs_integration_response
  ]
}

resource "aws_api_gateway_stage" "webhook_stage" {
  deployment_id = aws_api_gateway_deployment.webhook_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.trello_webhook_api.id
  stage_name    = var.api_stage_name

  tags = {
    Name        = "${var.environment}-trello-webhook-api-stage"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
