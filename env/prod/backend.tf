terraform {
  backend "s3" {
    bucket         = "trello-prod-tfstate"
    key            = "trello/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "trello-prod-tfstate-lock"
    encrypt        = true
  }
}
