data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    
  }

}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name   = "lambda_permissions"
  role   = aws_iam_role.lambda_exec_role.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}


data "aws_iam_policy_document" "lattice_ec2_client_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    
  }

}


data "aws_iam_policy_document" "lattice_invoke_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "vpc-lattice-svcs:Invoke"
    ]
    # resources = [aws_vpclattice_service.service_1.arn]
    resources = ["*"]
  }
}

resource "aws_iam_role" "lattice_ec2_client_role" {
  name = "lattice_ec2_client_role"
  assume_role_policy = data.aws_iam_policy_document.lattice_ec2_client_doc.json

}

# resource "aws_iam_role_policy" "lattice_ec2_client_policy" {
#   name = "lattice_ec2_client_policy"
#   role = aws_iam_role.lattice_ec2_client_role.id
#   policy = data.aws_iam_policy_document.lattice_ec2_client_doc.json
# }
resource "aws_iam_role_policy" "lattice_invoke_policy" {
  name = "lattice_invoke_policy"
  role = aws_iam_role.lattice_ec2_client_role.id
  policy = data.aws_iam_policy_document.lattice_invoke_policy_doc.json
}
resource "aws_iam_instance_profile" "lattice_ec2_client_profile" {
  name = "lattice_ec2_client"
  role = aws_iam_role.lattice_ec2_client_role.name
}

