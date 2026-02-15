terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "trello-queue-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "trello-queue-terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "trello-queue"
      Environment = "prod"
      ManagedBy   = "Terraform"
    }
  }
}
