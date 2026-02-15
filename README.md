# trello-queue-infra

Terraform infrastructure for Trello webhook processing using AWS services.

## Architecture

This infrastructure creates a serverless architecture for processing Trello webhooks:

- **API Gateway**: Receives incoming webhook POST requests from Trello
- **SQS Queue**: Buffers webhook messages for processing
- **Lambda Function**: Processes webhook messages from the queue
- **Dead Letter Queue**: Stores failed messages for investigation

## Directory Structure

```
trello-queue-infra/
├── env/
│   └── prod/                    # Production environment configuration
│       ├── main.tf              # Main Terraform configuration
│       ├── variables.tf         # Input variables
│       ├── outputs.tf           # Output values
│       └── versions.tf          # Terraform and provider versions
├── modules/
│   └── trello_webhook_stack/    # Reusable Trello webhook module
│       ├── main.tf              # Module resources
│       ├── variables.tf         # Module variables
│       └── outputs.tf           # Module outputs
├── .github/
│   └── workflows/
│       └── deploy-prod.yml      # GitHub Actions deployment workflow
└── README.md
```

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0
3. **AWS CLI** configured with credentials
4. **S3 Bucket** for Terraform state (e.g., `trello-queue-terraform-state`)
5. **DynamoDB Table** for state locking (e.g., `trello-queue-terraform-locks`)
6. **Lambda Deployment Package** at the specified path

## Setup

### 1. Create State Backend Resources

Before deploying, create the S3 bucket and DynamoDB table for Terraform state:

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket trello-queue-terraform-state \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket trello-queue-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name trello-queue-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 2. Prepare Lambda Package

Create a deployment package for your Lambda function:

```bash
mkdir -p lambda
cd lambda
# Add your Lambda function code here
zip trello-webhook-processor.zip index.js
cd ..
```

### 3. Deploy Infrastructure

```bash
cd env/prod
terraform init
terraform plan
terraform apply
```

## Configuration

### Environment Variables

The Lambda function can be configured with environment variables through the `lambda_environment_variables` variable:

```hcl
lambda_environment_variables = {
  TRELLO_API_KEY    = "your-api-key"
  TRELLO_API_SECRET = "your-api-secret"
  LOG_LEVEL         = "info"
}
```

### Customization

Key variables that can be customized in `env/prod/main.tf`:

- `lambda_runtime`: Node.js runtime version (default: nodejs18.x)
- `lambda_timeout`: Function timeout in seconds (default: 60)
- `lambda_memory_size`: Memory allocation in MB (default: 256)
- `sqs_batch_size`: Messages per Lambda invocation (default: 10)
- `api_stage_name`: API Gateway stage name (default: v1)

## Outputs

After deployment, the following outputs are available:

- `api_gateway_url`: The webhook endpoint URL to configure in Trello
- `sqs_queue_url`: SQS queue URL
- `lambda_function_name`: Lambda function name
- `dlq_url`: Dead Letter Queue URL

View outputs:
```bash
terraform output
```

## GitHub Actions Deployment

The repository includes a GitHub Actions workflow for automated deployment to production.

### Setup

1. Configure AWS credentials using OIDC:
   - Create an IAM role with appropriate permissions
   - Add the role ARN as `AWS_ROLE_ARN` secret in GitHub

2. The workflow triggers on:
   - Push to `main` branch
   - Manual workflow dispatch

### Workflow Steps

1. Checkout code
2. Configure AWS credentials
3. Setup Terraform
4. Format check
5. Initialize Terraform
6. Validate configuration
7. Plan changes
8. Apply changes (on main branch)

## Usage

### Webhook Configuration

1. Deploy the infrastructure
2. Get the API Gateway URL from outputs:
   ```bash
   terraform output api_gateway_url
   ```
3. Configure this URL as a webhook in Trello

### Monitoring

- **CloudWatch Logs**: Lambda function logs
- **SQS Metrics**: Queue depth, message age
- **API Gateway Metrics**: Request count, latency, errors
- **Dead Letter Queue**: Failed messages for investigation

## Security

- IAM roles follow principle of least privilege
- API Gateway integrates directly with SQS (no Lambda in the path)
- Lambda has minimal permissions (SQS read/write, CloudWatch logs)
- Terraform state is encrypted in S3
- State locking prevents concurrent modifications

## Maintenance

### Update Lambda Function

1. Update the Lambda package
2. Run `terraform apply` to deploy the new version

### Scale Configuration

Adjust these parameters based on your load:
- `sqs_batch_size`: Messages processed per invocation
- `lambda_memory_size`: More memory = faster processing
- `lambda_timeout`: Maximum processing time

### Cleanup

To destroy all resources:
```bash
cd env/prod
terraform destroy
```

## License

This project is licensed under the MIT License.