terraform {
  backend "s3" {
    bucket         = "trello-dev-tfstate"
    key            = "trello/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "trello-dev-tfstate-lock"
    encrypt        = true
  }
}
