data "aws_iam_policy_document" "lambda_target_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_target_1_exec_role" {
  name               = "service_1_lambda_target_1_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_target_assume_role.json
}

# generate an archive for the src/targets/lambda-target-1/index.js function
data "archive_file" "lambda_target_1" {
  type        = "zip"
  source_dir = "${path.module}/src/targets/lambda-target-1/"
  output_path = "${path.module}/src/targets/lambda-target-1/index.zip"
}

resource "aws_lambda_function" "lambda_target_1" {
  filename      = "${path.module}/src/consumer-1/index.zip"
  function_name = "lambda_target_1"
  role          = aws_iam_role.lambda_target_1_exec_role.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda_target_1.output_base64sha256

  runtime = "nodejs18.x"

#     depends_on = [
#     aws_iam_role_policy_attachment.lambda_logs,
#   ]

}

resource "aws_cloudwatch_log_group" "lambda_target_1_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_target_1.function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_target_1_logging" {
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

resource "aws_iam_policy" "lambda_target_1_logging" {
  name        = "lambda_target_1_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_target_1_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_target_1_logs" {
  role       = aws_iam_role.lambda_target_1_exec_role.name
  policy_arn = aws_iam_policy.lambda_target_1_logging.arn
}

