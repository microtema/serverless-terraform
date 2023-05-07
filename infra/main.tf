provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      hashicorp-learn = "lambda-api-gateway"
    }
  }
}

resource "random_pet" "product" {
  prefix = "microtema"
  length = 4
}

resource "aws_iam_role" "product" {
  name               = "ProductLambdaRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid : ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "template_file" "product_lambda_policy" {
  template = "${file("${path.module}/policy.json")}"
}

resource "aws_iam_policy" "product" {
  name        = "ProductLambdaPolicy"
  path        = "/"
  description = "IAM policy for Product lambda functions"
  policy      = data.template_file.product_lambda_policy.rendered
}

resource "aws_iam_role_policy_attachment" "product" {
  role       = aws_iam_role.product.name
  policy_arn = aws_iam_policy.product.arn
}

# create aws s3 bucket
resource "aws_s3_bucket" "product" {
  bucket = random_pet.product.id
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "product" {
  bucket = aws_s3_bucket.product.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

## create Bucket ACL with private ACL
resource "aws_s3_bucket_acl" "product" {
  depends_on = [aws_s3_bucket_ownership_controls.product]
  bucket     = aws_s3_bucket.product.id
  acl        = "private"
}

data "archive_file" "product" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/../lib/product.zip"
}

resource "aws_s3_object" "product" {

  bucket = aws_s3_bucket.product.id

  key    = "product.zip"
  source = data.archive_file.product.output_path

  etag = filemd5(data.archive_file.product.output_path)
}

# Create Product
resource "aws_lambda_function" "create_product" {
  function_name = "CreateProduct"

  s3_bucket = aws_s3_bucket.product.id
  s3_key    = aws_s3_object.product.key

  runtime = "nodejs12.x"
  handler = "createDocument.handler"

  environment {
    variables = {
      TABLE_NAME = "PRODUCT"
    }
  }

  source_code_hash = data.archive_file.product.output_base64sha256

  role = aws_iam_role.product.arn
}

resource "aws_cloudwatch_log_group" "create_product" {
  name = "/aws/lambda/${aws_lambda_function.create_product.function_name}"

  retention_in_days = 7
}

# Get Product
resource "aws_lambda_function" "get_product" {
  function_name = "GetDocument"

  s3_bucket = aws_s3_bucket.product.id
  s3_key    = aws_s3_object.product.key

  runtime = "nodejs12.x"
  handler = "getDocument.handler"
  environment {
    variables = {
      TABLE_NAME = "PRODUCT"
    }
  }

  source_code_hash = data.archive_file.product.output_base64sha256

  role = aws_iam_role.product.arn
}

resource "aws_cloudwatch_log_group" "get_product" {
  name = "/aws/lambda/${aws_lambda_function.get_product.function_name}"

  retention_in_days = 7
}

# Query Product
resource "aws_lambda_function" "query_product" {
  function_name = "QueryDocument"

  s3_bucket = aws_s3_bucket.product.id
  s3_key    = aws_s3_object.product.key

  runtime = "nodejs12.x"
  handler = "queryDocument.handler"
  environment {
    variables = {
      TABLE_NAME = "PRODUCT"
    }
  }

  source_code_hash = data.archive_file.product.output_base64sha256

  role = aws_iam_role.product.arn
}

resource "aws_cloudwatch_log_group" "query_product" {
  name = "/aws/lambda/${aws_lambda_function.query_product.function_name}"

  retention_in_days = 7
}

# Delete Product
resource "aws_lambda_function" "delete_product" {
  function_name = "DeleteDocument"

  s3_bucket = aws_s3_bucket.product.id
  s3_key    = aws_s3_object.product.key

  runtime = "nodejs12.x"
  handler = "deleteDocument.handler"
  environment {
    variables = {
      TABLE_NAME = "PRODUCT"
    }
  }

  source_code_hash = data.archive_file.product.output_base64sha256

  role = aws_iam_role.product.arn
}

resource "aws_cloudwatch_log_group" "delete_product" {
  name = "/aws/lambda/${aws_lambda_function.delete_product.function_name}"

  retention_in_days = 7
}

# REST API
resource "aws_api_gateway_rest_api" "product" {
  name        = "product"
  description = "Product API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "product" {
  rest_api_id = aws_api_gateway_rest_api.product.id
  parent_id   = aws_api_gateway_rest_api.product.root_resource_id
  path_part   = "product"
}

resource "aws_dynamodb_table" "product_table" {
  name         = "PRODUCT"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "product_id"

  attribute {
    name = "product_id"
    type = "S"
  }
  attribute {
    name = "category"
    type = "S"
  }
  attribute {
    name = "product_rating"
    type = "N"
  }

  global_secondary_index {
    name            = "ProductCategoryRatingIndex"
    hash_key        = "category"
    range_key       = "product_rating"
    projection_type = "ALL"
  }
}

# Create product
resource "aws_api_gateway_method" "create_product" {
  rest_api_id   = aws_api_gateway_rest_api.product.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_product" {
  rest_api_id             = aws_api_gateway_rest_api.product.id
  resource_id             = aws_api_gateway_method.create_product.resource_id
  http_method             = aws_api_gateway_method.create_product.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_product.invoke_arn
}

resource "aws_lambda_permission" "create_product" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.product.execution_arn}/*/POST/product"
}

# Get product
resource "aws_api_gateway_method" "get_product" {
  rest_api_id   = aws_api_gateway_rest_api.product.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = "GET"
  authorization = "NONE"
}

# https://stackoverflow.com/questions/41371970/accessdeniedexception-unable-to-determine-service-operation-name-to-be-authoriz
# Using GET for lambda integrations on AWS API Gateway may leave you wondering why POST integrations are working but GET integrations don't work.
# GET AWS_PROXY integrations will fail if GET is used as the method on the integration.
# POST should be used for the lambda integration, even if the OPEN API specification is for a get method.
resource "aws_api_gateway_integration" "get_product" {
  rest_api_id             = aws_api_gateway_rest_api.product.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.get_product.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_product.invoke_arn
}

resource "aws_lambda_permission" "get_product" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.product.execution_arn}/*/GET/product"
}

# Query product
resource "aws_api_gateway_method" "query_product" {
  rest_api_id   = aws_api_gateway_rest_api.product.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = "PATCH"
  authorization = "NONE"
}

# https://stackoverflow.com/questions/41371970/accessdeniedexception-unable-to-determine-service-operation-name-to-be-authoriz
# Using GET for lambda integrations on AWS API Gateway may leave you wondering why POST integrations are working but GET integrations don't work.
# GET AWS_PROXY integrations will fail if GET is used as the method on the integration.
# POST should be used for the lambda integration, even if the OPEN API specification is for a get method.
resource "aws_api_gateway_integration" "query_product" {
  rest_api_id             = aws_api_gateway_rest_api.product.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.query_product.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.query_product.invoke_arn
}

resource "aws_lambda_permission" "query_product" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.product.execution_arn}/*/PATCH/product"
}

# Delete product
resource "aws_api_gateway_method" "delete_product" {
  rest_api_id   = aws_api_gateway_rest_api.product.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_product" {
  rest_api_id             = aws_api_gateway_rest_api.product.id
  resource_id             = aws_api_gateway_method.delete_product.resource_id
  http_method             = aws_api_gateway_method.delete_product.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_product.invoke_arn
}

resource "aws_lambda_permission" "delete_product" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.product.execution_arn}/*/DELETE/product"
}

# deploy REST API
resource "aws_api_gateway_deployment" "product" {
  depends_on = [
    aws_api_gateway_integration.create_product,
    aws_api_gateway_integration.get_product,
    aws_api_gateway_integration.query_product,
    aws_api_gateway_integration.delete_product
  ]
  rest_api_id = aws_api_gateway_rest_api.product.id
  stage_name  = "dev"
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.product.id
  rest_api_id   = aws_api_gateway_rest_api.product.id
  stage_name    = "prod"
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.product.id
  rest_api_id   = aws_api_gateway_rest_api.product.id
  stage_name    = "stage"
}