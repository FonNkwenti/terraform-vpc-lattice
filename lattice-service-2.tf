# create vpc lattice service for lambda target group
resource "aws_vpclattice_service" "service_2" {
  name = "service-2"
  auth_type = "NONE"
  # depends_on = [
  #   aws_vpclattice_target_group.alb_tg
  # ]
}


resource "aws_cloudwatch_log_group" "lattice_service_2_log_group" {
  name              = "/aws/lattice/service/service-2"
  retention_in_days = 7
}

# log subscription for lattice service
resource "aws_vpclattice_access_log_subscription" "lattice_service_2_log_subscription" {
  resource_identifier = aws_vpclattice_service.service_2.id
  destination_arn     = aws_cloudwatch_log_group.lattice_service_2_log_group.arn
}


#create a lambda target group
resource "aws_vpclattice_target_group" "alb_tg" {
  name = "alb-tg"
  type = "ALB"

  config {
    vpc_identifier = aws_vpc.alb_vpc.id

    port             = 80
    protocol         = "HTTP"
    protocol_version = "HTTP1"
  }
  tags = {
    Name        = "alb-tg"
 }

}

# create vpc lattice target group attachment
resource "aws_vpclattice_target_group_attachment" "alb_tg_attachement" {
  target_group_identifier = aws_vpclattice_target_group.alb_tg.arn
  target {
    id = aws_lb.service_2_alb.arn
    port = 80
  }
#   depends_on = [ aws_vpclattice_target_group.alb_tg ]
}


# use aws_vpclattice_listener resource to create listeners and rules for our service-2 and alb-tg

resource "aws_vpclattice_listener" "http_listener" {
  name               = "http-listener"
  protocol           = "HTTP"
  service_identifier = aws_vpclattice_service.service_2.id

  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.alb_tg.id
      }
    }
  }
  # default_action {
  #   fixed_response {
  #     status_code = 404
  #   }
  # }
}


# listener rule for path based routing to lambda target groups
# resource "aws_vpclattice_listener_rule" "service_network_listener_rule" {
#   name                = "service-network-listener-rule"
#   listener_identifier = aws_vpclattice_listener.https_listener.arn
#   service_identifier  = aws_vpclattice_service.service_2.id
#   priority            = 10
#   match {
#     http_match {
#       path_match {
#         case_sensitive = false
#         match {
#           prefix = "/path-1"
#         }
#       }
#     }
#   }
#   # action {
#   #   fixed_response {
#   #     status_code = 404
#   #   }

#   # }
    
#     action {
#         forward {
#         target_groups {
#             target_group_identifier = aws_vpclattice_target_group.alb_tg.id
#         }

#         }

#     }
    
# depends_on = [ aws_vpclattice_listener.https_listener ]
# }


output "lattice_service_2_id" {
    value = aws_vpclattice_service.service_2.id
}
output "lattice_service_2_arn" {
    value = aws_vpclattice_service.service_2.arn
}

output "lattice_service_2_network_dns_entry_domain_name" {
  value = aws_vpclattice_service.service_2.dns_entry[0].domain_name
}
