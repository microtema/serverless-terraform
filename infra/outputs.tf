# Output value definitions

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.product.id
}

output "function_create_product" {
  description = "Name of the create_document Lambda function."

  value = aws_lambda_function.create_product.function_name
}

output "function_get_product" {
  description = "Name of the get_document Lambda function."

  value = aws_lambda_function.get_product.function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_api_gateway_deployment.product.invoke_url
}