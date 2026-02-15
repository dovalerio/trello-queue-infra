variable "function_name" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
}

variable "timeout" {
  type    = number
  default = 10
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "artifact_bucket" {
  type = string
}

variable "artifact_key" {
  type = string
}

variable "artifact_object_version" {
  type    = string
  default = null
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "sqs_queue_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
