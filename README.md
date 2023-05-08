# Infrastructure as Code (IaC): Terraform and AWS Serverless

... is a way of managing your devices and servers through machine-readable definition files. Basically, you write down how you want your infrastructure to look like and what code should be run on that infrastructure. Then, with the push of a button you say “Deploy my infrastructure”. BAM, there is your application, running on a server, against a database, available through an API, ready to be used! And you just defined all of that infrastructure using IaC.

> IaC is a key practice of DEVOPS teams and integrates as part of the CI/CD pipeline.

A great Infrastructure as Code tool is Terraform by HashiCorp. (https://www.terraform.io/)
Personally I use it to provide and maintain infrastructure on AWS. And I’ve had a great experience doing that.

![scope_and_context.png](Resources/scope_and_context.png)

## Overview

I will demonstrate IaC by working out an example. 
We are going to set up an application on AWS. 
I provisioned the code on GitHub: https://github.com/microtema/serverless-terraform.git
A user can enter a coding tip and see all the coding tips that other users have entered. 
The tips are stored in a NoSQL database which is AWS DynamoDB. 
Storing and retrieving these tips is done by the Lambda Functions which fetch or put the tips from and to the database. For the application to be useful, users have to be able to call these Lambda Functions. So we expose the Lambda Functions through AWS API Gateway. 

Here is an architectural overview of the application:

![scope_and_context.png](Resources/scope_and_context_scope.png)

### API Gateway

API Gateway is a fully managed service provided by AWS that makes it easy for developers to create, publish, and manage APIs for their applications. The service acts as a "front door" for applications, providing a secure and scalable interface for clients to access backend resources and services.

API Gateway supports a wide range of API types, including REST APIs and WebSocket APIs, and provides a variety of features and functionality, such as:

* API Creation and Configuration: Developers can use the API Gateway console, CLI, or APIs to create and configure APIs, including endpoints, methods, authentication, and other settings.

* API Deployment and Management: APIs can be deployed to multiple stages, such as development, staging, and production, allowing developers to easily manage versioning, testing, and release cycles. The service also provides detailed monitoring and logging capabilities to help developers diagnose issues and optimize performance.

* Security and Authentication: API Gateway supports a variety of authentication methods, including AWS Identity and Access Management (IAM), Lambda authorizers, and custom authorizers, allowing developers to control access to their APIs and resources.

* Scaling and Performance: API Gateway can automatically scale to handle large volumes of traffic and can integrate with other AWS services, such as Amazon EC2, AWS Lambda, and AWS Elastic Beanstalk, to provide additional compute resources and improve performance.

* Integration with Other AWS Services: API Gateway can be used to integrate with other AWS services, such as AWS Lambda, AWS Step Functions, and Amazon S3, to create powerful and flexible applications and workflows.

Overall, API Gateway provides a powerful and flexible platform for building modern, scalable, and secure APIs that can be easily integrated into any application or workflow.

### AWS Lambda

AWS Lambda is a serverless computing platform provided by Amazon Web Services (AWS) that enables developers to run code without having to provision or manage servers. With AWS Lambda, developers can simply upload their code to the service and it will automatically scale and run the code in response to requests or events, without needing to worry about infrastructure or resource management.

AWS Lambda supports a wide range of programming languages, including Node.js, Python, Java, C#, Go, and Ruby, and can be used to build a variety of applications and services, such as APIs, web applications, and backend services. The platform provides a variety of features and functionality, including:

* Flexible and Scalable: AWS Lambda can automatically scale to handle large volumes of traffic and can be used to build highly available and fault-tolerant applications. The platform also provides a variety of configuration options, such as memory and timeout settings, to optimize performance and cost.

* Event-Driven Computing: AWS Lambda can be used to build event-driven applications that respond to events, such as changes to data in Amazon S3 or updates to a database, in real-time. The platform provides a variety of event sources, such as AWS SNS, AWS SQS, and AWS Kinesis, to trigger the execution of Lambda functions.

* Integration with Other AWS Services: AWS Lambda can be integrated with other AWS services, such as Amazon S3, Amazon DynamoDB, and Amazon API Gateway, to build complex and powerful applications and workflows.

* Security and Authentication: AWS Lambda provides a variety of security features, such as encryption at rest and in transit, and can be integrated with other AWS services, such as AWS Identity and Access Management (IAM), to control access to resources and services.

Overall, AWS Lambda provides a powerful and flexible platform for building serverless applications and services that are highly scalable, cost-effective, and easy to manage.

### IAM Policy


IAM (Identity and Access Management) policies are a set of rules that define the permissions granted to a specific user, group, or role in an AWS account. IAM policies are used to control access to AWS services and resources, and can be used to enforce security policies, regulatory compliance, and other governance requirements.

An IAM policy is a JSON document that consists of a set of statements, each of which defines a specific permission or set of permissions. Each statement includes an action, which defines the operation being performed (such as "ec2:StartInstance" or "s3:ListBucket"), a resource, which defines the AWS resource that the action is being performed on (such as an Amazon S3 bucket or an EC2 instance), and a set of conditions, which can be used to further restrict access.

IAM policies can be attached to individual users, groups, or roles, and can be inherited or overridden by other policies. IAM policies can also be used in combination with AWS Organizations to manage access to multiple AWS accounts from a central location.

IAM policies can be created and managed using the AWS Management Console, the AWS CLI, or programmatically using the AWS SDKs. IAM policies are a powerful tool for managing access to AWS resources and services, and are an essential component of any security and compliance strategy on the AWS platform.

### IAM Roles

IAM (Identity and Access Management) roles are a secure way to grant permissions to entities in AWS, such as AWS services, users, and groups. IAM roles are used to grant temporary permissions to entities, rather than providing permanent access keys, which can enhance security and reduce the risk of unauthorized access.

IAM roles can be created and assigned to AWS resources, such as EC2 instances, AWS Lambda functions, and Amazon RDS instances, to provide these resources with access to other AWS services or resources. For example, an EC2 instance can be assigned an IAM role that allows it to read and write to an S3 bucket, without requiring any additional authentication or access keys.

IAM roles have a set of policies attached to them that define the permissions granted to the role. These policies can be created and managed in a similar way to IAM policies. IAM roles can also have trust relationships defined for them, which specify which entities are allowed to assume the role.

One of the key benefits of using IAM roles is that they can be assumed by any entity that is authorized to do so. For example, an EC2 instance can assume an IAM role assigned to it, or a user can assume a role assigned to them using the AWS Management Console, the AWS CLI, or programmatically using the AWS SDKs.

Overall, IAM roles provide a flexible and secure way to manage access to AWS resources and services, and are an essential component of any security and compliance strategy on the AWS platform.

### Amazon DynamoDB

Amazon DynamoDB is a fully managed NoSQL database service provided by Amazon Web Services (AWS). DynamoDB is designed to provide fast and predictable performance at any scale, with low latency and high throughput for both read and write operations. DynamoDB is used by organizations of all sizes for a wide range of use cases, including web and mobile applications, gaming, ad tech, IoT, and more.

DynamoDB is a key-value and document database that stores data in tables, where each table consists of items and attributes. Items are similar to rows in a traditional relational database, and attributes are similar to columns. However, unlike traditional databases, DynamoDB does not enforce a fixed schema, and items in a table can have different attributes. This allows for more flexibility in data modeling, and can simplify development and maintenance of applications.

DynamoDB supports a variety of features, including:

* Fully managed: DynamoDB is a fully managed service that automates database administration tasks, such as hardware provisioning, software patching, and backups. This allows developers to focus on building applications, rather than managing infrastructure.

* Highly scalable: DynamoDB can scale to handle millions of requests per second, with automatic partitioning and load balancing. This makes DynamoDB well-suited for applications with unpredictable or rapidly changing workloads.

* Low latency and high throughput: DynamoDB provides predictable performance, with low latency and high throughput for both read and write operations. This allows applications to scale seamlessly without sacrificing performance.

* ACID transactions: DynamoDB supports ACID transactions for individual items or groups of items, providing strong consistency for critical data.

* Global tables: DynamoDB supports global tables, which enable multi-region, multi-master deployments for low-latency global access to data.

DynamoDB can be accessed using a variety of APIs and SDKs, including the AWS Management Console, the AWS CLI, and the AWS SDKs for popular programming languages such as Node.js, Python, Java, and more. Overall, DynamoDB provides a powerful and flexible NoSQL database service that is well-suited for a wide range of applications and use cases.

### CloudWatch

Amazon CloudWatch is a monitoring and observability service provided by Amazon Web Services (AWS). CloudWatch allows users to collect, monitor, and analyze metrics, logs, and events from a wide variety of AWS resources, services, and custom applications. CloudWatch provides real-time visibility into application and infrastructure performance, and helps users detect and diagnose issues quickly.

CloudWatch supports a wide range of features, including:

* Metrics: CloudWatch allows users to collect and monitor metrics from AWS resources, such as EC2 instances, RDS databases, Lambda functions, and more. Users can also publish custom metrics to CloudWatch using the CloudWatch API or SDKs. CloudWatch provides pre-built dashboards and alarms to help users visualize and alert on metrics.

* Logs: CloudWatch allows users to collect, monitor, and analyze logs from AWS resources, such as EC2 instances, ECS containers, and Lambda functions. Users can also publish custom logs to CloudWatch using the CloudWatch API or SDKs. CloudWatch provides advanced search and analytics capabilities, and supports integration with popular third-party log management tools.

* Events: CloudWatch allows users to monitor and respond to events from AWS resources, such as EC2 Auto Scaling, S3, and Lambda. Users can create rules that trigger automated actions, such as scaling or notifications, based on specific events.

* Alarms: CloudWatch allows users to set up alarms based on metrics or events, and receive notifications when thresholds are breached. Alarms can be used to trigger automated actions, such as scaling or recovery, in response to specific conditions.

* Dashboards: CloudWatch provides customizable dashboards that allow users to visualize and monitor metrics and logs in real-time.

CloudWatch can be accessed using a variety of APIs and SDKs, including the AWS Management Console, the AWS CLI, and the AWS SDKs for popular programming languages such as Node.js, Python, Java, and more. CloudWatch provides a powerful and flexible monitoring and observability service that is essential for operating and maintaining modern cloud applications and infrastructure.

## Create Application

We will now go over the steps to set up the application you see in the demo above. IaC is the main focus. I will show the code and AWS CLI commands that are necessary but I will not explain them in detail since that is not the purpose of this blog. I’ll focus on the Terraform definitions instead. 
You are welcome to follow along by cloning the repository that I linked to in this blog post.

### PREREQUISITES

* Install Terraform
* Install AWS CLI
* Checkout the repository on GitHub: https://github.com/microtema/serverless-terraform.git
* Be ready to get your mind blown by IaC

#### Terraform Basic

The main things you’ll be configuring with Terraform are resources. 
Resources are the components of your application infrastructure. 
E.g: a Lambda Function, an API Gateway Deployment, a DynamoDB database, … A resource is defined by using the keyword resource followed by the type and the name. 
The name can be arbitrarily chosen. 
The type is fixed. For example: resource "aws_dynamodb_table" "product-dynamodb-table"

To follow along with this blog post you have to know two basic Terraform commands.

```
terraform apply
```

Terraform apply will start provisioning all the infrastructure you defined. Your databases will be created. 
Your Lambda Functions will be set up. The API Gateway will be set in place.

```
terraform destroy
```

Terraform destroy will remove all the infrastructure that you have set up in the cloud. 
If you are using Terraform correctly you should not have to use this command. 
However should you want to start over, you can remove all the existing infrastructure with this command. 
No worries, you will still have all the infrastructure neatly described on your machine because you are using Infrastructure as Code.

#### DATABASE: DYNAMODB

Let’s start with the basis. Where will all our coding tips be stored? That’s right, in the database. This database is part of our infrastructure

```
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
```

Since Dynamo is a NoSQL database, we don’t have to specify all attributes upfront. The only thing we have to provide are the elements that AWS will use to build the partition key with. When you provide a hash key as well as a sort key, AWS will combine these to make a unique partition key. Mind the word UNIQUE. Make sure this combination is unique.

> DynamoDB uses the partition key value as input to an internal hash function. The output from the hash function determines the partition (physical storage internal to DynamoDB) in which the item will be stored. All items with the same partition key value are stored together, in sorted order by sort key value. – from AWS docs: DynamoDB Core Components

From the attribute definitions in main.tf it is clear that category (S) is a string and Date (N) should be a number.

### IAM

Before specifying the Lambda Functions we have to create permissions for our functions to use. This makes sure that our functions have permissions to access other resources (like DynamoDB). Without going too deep into it, the AWS permission model works as follows:

* Provide a resource with a role
* Add permissions to this role
* These allow the role to access other resources:
  * permissions for triggering another resource (eg. Lambda Function forwards logs to CloudWatch)
  * permissions for being triggered by another resource (eg. Lambda Function may be triggered by API Gateway)

```
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
```

### IAM Policy

In the example above, the first resource that is defined is an aws_iam_role. This is the role that we will later give to our Lambda Functions.

```
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
```

#### policy.json
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/PRODUCT"
    }
  ]
}
```

We then create the aws_iam_role_policy resource which we link to the aws_iam_role. The first aws_iam_role_policy is giving this role permission to invoke any action on the specified DynamoDB resource. The second role_policy allows a resource with this role to send logs to CloudWatch.

A couple of things to notice:

* The aws_iam_role and the aws_iam_role_policy are connected by the role argument of the role_policy resource
* In the statement attribute of the aws_iam_role_policy we grant (Effect attr.) permission to do some actions (Action attr.) on a certain resource (Resource attr.)
* A resource is referenced by its ARN or Amazon Resource Name which uniquely identifies this resource on AWS
* There are two ways to specify an aws_iam_role_policy:
  * using the until EOF syntax (like I did here)
  using a separate Terraform aws_iam_policy_document element that is coupled to the aws_iam_role_policy
  * The dynamodb-lambda-policy allows all actions on the specified DynamoDB resource because under the Action attribute it states dynamodb:* You could make this more restricted and mention actions like

> "dynamodb:Scan", "dynamodb:BatchWriteItem","dynamodb:PutItem"

### LAMBDA FUNCTIONS

There are four Lambda Functions that are part of this application. 

#### The first Lambda is used to get or retrieve the product from the database further referenced as the getDocument. 

```
const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TableName = process.env.TABLE_NAME;

module.exports.handler = async (event) => {

    const params = {
        TableName,
        Key: {...event.queryStringParameters}
    }

    try {
        const data = await docClient.get(params).promise()
        return {body: JSON.stringify(data.Item)}
    } catch (e) {
        return {error: "Unable to get document!", message: e.message}
    }
}
```

#### The second Lambda is used to post or send the product to the database.

```
const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TableName = process.env.TABLE_NAME;

module.exports.handler = async (event) => {

    const Item = JSON.parse(event.body);

    const params = {TableName, Item}

    try {
        await docClient.put(params).promise();
        return {body: 'Successfully created item!'}
    } catch (e) {
        return {error: "Unable to create document!", message: e.message}
    }
}
```

### The third Lambda is used to delete or remove the product from the database.

```
const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TableName = process.env.TABLE_NAME;

module.exports.handler = async (event) => {

    const params = {
        TableName,
        Key: {...event.queryStringParameters}
    }

    try {
        await docClient.delete(params).promise()
        return {
            statusCode: 200,
            body: JSON.stringify({message: "Item Deleted"}),
        };
    } catch (e) {
        return {error: "Unable to delete document!", message: e.message}
    }
}
```

### The four Lambda is used to search or retrieve the products from the database.

```
const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const TableName = process.env.TABLE_NAME;

module.exports.handler = async (event) => {

    const {product_id} = event.queryStringParameters

    const params = {
        TableName,
        KeyConditionExpression: '#name = :value',
        ExpressionAttributeValues: {':value': product_id},
        ExpressionAttributeNames: {'#name': 'product_id'}
    }

    try {
        const data = await docClient.query(params).promise()
        return {body: JSON.stringify(data.Items)}
    } catch (e) {
        return {error: "Unable to query document!", message: e.message}
    }
}
```

Notice that we tell Terraform the S3 Bucket and directory to look for the code
We specify the runtime and memory for this Lambda Function
index.handler points to the file and function where to enter the code
The aws_iam_role resource is the permission that states that this Lambda Function may be invoked by the API Gateway that we created

### API GATEWAY

I kept the most difficult one for last. On the other hand, it is also the most interesting.

```
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
```

```
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
```

### TESTING

```
curl https://tq107g74c1.execute-api.eu-central-1.amazonaws.com/dev/product?product_id=6
```

```
{
"product_rating": 4,
"product_name": "<<Product Name>>",
"product_price": 12,
"category": "Category",
"product_description": "Product description",
"product_id": "6"
}
```