data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    
  }

}

data "aws_iam_policy_document" "lambda_private_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface",
      "vpc-lattice:Invoke",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "consumer_1_lambda_exec_role" {
  name               = "consumer_1_lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "consumer_1_lambda_private_permissions" {
  name   = "consumer_1_lambda_private_permissions"
  role   = aws_iam_role.consumer_1_lambda_exec_role.id
  policy = data.aws_iam_policy_document.lambda_private_permissions.json
}

resource "aws_iam_role_policy" "lambda_lattice_invoke_policy" {
  name   = "lambda_lattice_invoke_policy"
  role   = aws_iam_role.consumer_1_lambda_exec_role.id
  policy = data.aws_iam_policy_document.lattice_invoke_policy_doc.json
}
# generate an archive for the src/consumer-1/index.js function
data "archive_file" "consumer_1_lambda" {
  type        = "zip"
  source_dir = "${path.module}/src/consumer-1/"
  output_path = "${path.module}/src/consumer-1/index.zip"
}

resource "aws_lambda_function" "consumer_1_lambda" {
  filename      = "${path.module}/src/consumer-1/index.zip"
  function_name = "consumer_1_lambda"
  role          = aws_iam_role.consumer_1_lambda_exec_role.arn
  handler       = "index.handler"
  timeout = "30"

  source_code_hash = data.archive_file.consumer_1_lambda.output_base64sha256

  runtime = "nodejs18.x"

  vpc_config {
    subnet_ids = [aws_subnet.subnet1_vpc1.id, aws_subnet.subnet2_vpc1.id]
    security_group_ids = [aws_security_group.lattice-client-sg.id]
  }

    depends_on = [
    aws_iam_role_policy_attachment.consumer_1_lambda_logs,
  ]

  environment {
    variables = {
      LATTICE_SERVICE_ENDPOINT  = aws_vpclattice_service.service_1.dns_entry[0].domain_name
    }
  }

}



resource "aws_cloudwatch_log_group" "consumer_1_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.consumer_1_lambda.function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "consumer_1_lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "consumer_1_lambda_logging" {
  name        = "consumer_1_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.consumer_1_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "consumer_1_lambda_logs" {
  role       = aws_iam_role.consumer_1_lambda_exec_role.name
  policy_arn = aws_iam_policy.consumer_1_lambda_logging.arn
}