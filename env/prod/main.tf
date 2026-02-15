terraform {
  required_version = ">= 1.0"
}

module "trello_webhook_stack" {
  source = "../../modules/trello_webhook_stack"
}
