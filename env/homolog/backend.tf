terraform {
  backend "s3" {
    bucket         = "trello-homolog-tfstate"
    key            = "trello/homolog/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "trello-homolog-tfstate-lock"
    encrypt        = true
  }
}
