# Output value definitions

output "base_url" {
  description = "Base URL for OPEN API Gateway stage."
  value = aws_api_gateway_deployment.product.invoke_url
}