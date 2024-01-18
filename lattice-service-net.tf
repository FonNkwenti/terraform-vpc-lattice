
# create amazon vpc lattice service network
resource "aws_vpclattice_service_network" "service_network" {
  name = "service-network"
}

# Todo - auth policy for service network


# create vpc lattice service for lambda target group
resource "aws_vpclattice_service" "service_1" {
  name = "service-1"
  auth_type = "NONE"
  depends_on = [
    aws_vpclattice_target_group.lambda_1_tg
  ]
}

# create vpc lattice service network service association for our service
resource "aws_vpclattice_service_network_service_association" "service_association" {
    service_identifier = aws_vpclattice_service.service_1.id
    service_network_identifier = aws_vpclattice_service_network.service_network.id

}

# Todo auth policy for service
#################
resource "aws_vpclattice_access_log_subscription" "log_subscription" {
  resource_identifier = aws_vpclattice_service.service_1.id
  destination_arn     = aws_cloudwatch_log_group.log_group_lattice.arn
}
resource "aws_cloudwatch_log_group" "log_group_lattice" {
  name              = "/aws/lattice/service/service-1"
  retention_in_days = 7
}



#create a lambda target group
resource "aws_vpclattice_target_group" "lambda_1_tg" {
  name = "lambda-tg"
  type = "LAMBDA"
}

# create vpc lattice target group attachment
resource "aws_vpclattice_target_group_attachment" "lambda_1_tg_attachement" {
  target_group_identifier = aws_vpclattice_target_group.lambda_1_tg.id
  target {
    # id = aws_lambda_function.lambda_function.arn
    id = "arn:aws:lambda:us-west-2:404148889442:function:cloudgto-service-builder-prv-build-s3"
  }
  depends_on = [ aws_vpclattice_target_group.lambda_1_tg ]


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
  priority            = 20
  match {
    http_match {
      path_match {
        case_sensitive = true
        match {
          prefix = "/path-1"
        }
      }
    }
  }
  # action {
  #   fixed_response {
  #     status_code = 404
  #   }

  # }
  action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.lambda_1_tg.id
      }

    }

  }

depends_on = [ aws_vpclattice_listener.https_listener ]
}

resource "aws_vpclattice_service_network_vpc_association" "vpc_1_association" {
  vpc_identifier             = aws_vpc.vpc_1.id
  service_network_identifier = aws_vpclattice_service_network.service_network.id
#   security_group_ids         = [aws_security_group.example.id]
}


