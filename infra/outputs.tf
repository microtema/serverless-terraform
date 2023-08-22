# Output value definitions

output "base_url" {
  description = "Base URL for OPEN API Gateway stage."
  value       = aws_api_gateway_deployment.product.invoke_url
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.product.id
}
output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.product.arn
}
output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.product.id
}
output "product_table_arn" {
  value = aws_dynamodb_table.product_table.arn
}