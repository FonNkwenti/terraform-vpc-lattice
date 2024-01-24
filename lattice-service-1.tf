# create vpc lattice service for lambda target group
resource "aws_vpclattice_service" "service_1" {
  name = "service-1"
  auth_type = "NONE"
  depends_on = [
    aws_vpclattice_target_group.lambda_1_tg
  ]
}


# This auth policy only allows traffic from the associated service network and allows only authenticated requests:
/*
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "vpc-lattice-svcs:Invoke",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "vpc-lattice-svcs:ServiceNetworkArn": "arn:aws:vpc-lattice:us-east-1:001122334455:servicenetwork/your-service-network-id"
                },
                "StringNotEquals": {
                    "aws:PrincipalType": "Anonymous"
                }
            }
        }
    ]
}
*/
#################


resource "aws_cloudwatch_log_group" "lattice_service_1_log_group" {
  name              = "/aws/lattice/service/service-1"
  retention_in_days = 7
}

# log subscription for lattice service
resource "aws_vpclattice_access_log_subscription" "lattice_service_1_log_subscription" {
  resource_identifier = aws_vpclattice_service.service_1.id
  destination_arn     = aws_cloudwatch_log_group.lattice_service_1_log_group.arn
}


#create a lambda target group
resource "aws_vpclattice_target_group" "lambda_1_tg" {
  name = "lambda-tg"
  type = "LAMBDA"
#   tags = {
#     Name        = "Lambda 1 Target Group"
#  }

}

# create vpc lattice target group attachment
resource "aws_vpclattice_target_group_attachment" "lambda_1_tg_attachement" {
  target_group_identifier = aws_vpclattice_target_group.lambda_1_tg.arn
  target {
    id = aws_lambda_function.lambda_target_1.arn
    # port = 80
  }
#   depends_on = [ aws_vpclattice_target_group.lambda_1_tg ]
}


# use aws_vpclattice_listener resource to create listeners and rules for our service-1 and lambda-tg

resource "aws_vpclattice_listener" "https_listener" {
  name               = "https-listener"
  protocol           = "HTTPS"
  service_identifier = aws_vpclattice_service.service_1.id

#   default_action {
#     forward {
#       target_groups {
#         target_group_identifier = aws_vpclattice_target_group.lambda_target.id
#       }
#     }
#   }
  default_action {
    fixed_response {
      status_code = 404
    }
  }
}


# listener rule for path based routing to lambda target groups
resource "aws_vpclattice_listener_rule" "service_network_listener_rule" {
  name                = "service-network-listener-rule"
  listener_identifier = aws_vpclattice_listener.https_listener.arn
  service_identifier  = aws_vpclattice_service.service_1.id
  priority            = 10
  match {
    http_match {
      path_match {
        case_sensitive = false
        match {
          prefix = "/path-1"
        }
      }
    }
  }
  action {
    fixed_response {
      status_code = 404
    }

  }
    
    # action {
    #     forward {
    #     target_groups {
    #         target_group_identifier = aws_vpclattice_target_group.lambda_1_tg.id
    #     }

    #     }

    # }
    
depends_on = [ aws_vpclattice_listener.https_listener ]
}


output "lattice_service_1_id" {
    value = aws_vpclattice_service.service_1.id
}
output "lattice_service_1_arn" {
    value = aws_vpclattice_service.service_1.arn
}

output "lattice_service_1_network_dns_entry_domain_name" {
  value = aws_vpclattice_service.service_1.dns_entry[0].domain_name
}
