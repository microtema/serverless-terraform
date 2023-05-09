provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      hashicorp-learn = "lambda-api-gateway"
    }
  }
}

resource "random_pet" "product" {
  prefix = "product"
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
  tags = {
    Name        = "Product API CRUD operations"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "product" {
  bucket = aws_s3_bucket.product.id
  versioning_configuration {
    status = "Enabled"
  }
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
  description = "Create a Product"

  s3_bucket = aws_s3_bucket.product.id
  s3_key    = aws_s3_object.product.key

  runtime = var.node_runtime
  handler = "createProduct.handler"

  environment {
    variables = {
      TABLE_NAME = var.table_name
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
  function_name = "GetProduct"
  description = "Get a Product by Product ID"

  s3_bucket = aws_s3_bucket.product.id
  s3_key    = aws_s3_object.product.key

  runtime = var.node_runtime
  handler = "getProduct.handler"
  environment {
    variables = {
      TABLE_NAME = var.table_name
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
  function_name = "QueryProduct"
  description = "Search products by filter"

  s3_bucket = aws_s3_bucket.product.id
  s3_key    = aws_s3_object.product.key

  runtime = var.node_runtime
  handler = "queryProduct.handler"
  environment {
    variables = {
      TABLE_NAME = var.table_name
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
  function_name = "DeleteProduct"
  description = "Delete a Product by given product ID"

  s3_bucket = aws_s3_bucket.product.id
  s3_key    = aws_s3_object.product.key

  runtime = var.node_runtime
  handler = "deleteProduct.handler"
  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }

  source_code_hash = data.archive_file.product.output_base64sha256

  role = aws_iam_role.product.arn
}

resource "aws_cloudwatch_log_group" "delete_product" {
  name = "/aws/lambda/${aws_lambda_function.delete_product.function_name}"

  retention_in_days = 7
}

data "template_file" "product" {

  template = file("${path.module}/openapi.yaml")

  vars = {
    get_product_lambda_arn  = aws_lambda_function.get_product.arn
    delete_product_lambda_arn = aws_lambda_function.delete_product.arn
    create_product_lambda_arn = aws_lambda_function.create_product.arn
    query_product_lambda_arn = aws_lambda_function.query_product.arn

    aws_region              = var.aws_region
    lambda_identity_timeout = var.lambda_identity_timeout
  }
}

resource "aws_api_gateway_rest_api" "product" {
  name           = "product"
  description    = "Product OPEN API Gateway"
  api_key_source = "HEADER"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = data.template_file.product.rendered
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
resource "aws_lambda_permission" "create_product" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.product.execution_arn}/*/POST/product"
}

resource "aws_lambda_permission" "get_product" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.product.execution_arn}/*/GET/product/*"
}

# Query product
resource "aws_lambda_permission" "query_product" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.product.execution_arn}/*/GET/product"
}

# Delete product
resource "aws_lambda_permission" "delete_product" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_product.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.product.execution_arn}/*/DELETE/product/*"
}

# Deploy REST API
resource "aws_api_gateway_deployment" "product" {
  depends_on  = []
  rest_api_id = aws_api_gateway_rest_api.product.id
  stage_name  = "dev"
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.product.id
  rest_api_id   = aws_api_gateway_rest_api.product.id
  stage_name    = "stage"
}