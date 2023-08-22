# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-central-1"
}

variable "lambda_identity_timeout" {

  description = "Lambda Identy timeout"

  type    = number
  default = 2000
}
variable "table_name" {

  description = "Product table name"

  type = string

  default = "PRODUCT"
}

variable "node_runtime" {

  description = "NodeJS runtime version"
  type = string
  default = "nodejs14.x"
}