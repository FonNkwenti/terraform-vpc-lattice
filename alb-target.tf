resource "aws_vpc" "alb_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "alb-vpc"
  }
}

resource "aws_subnet" "asg_subnet_1" {
  vpc_id                  = aws_vpc.alb_vpc.id
  cidr_block             = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-2a"
tags = {
    Name = "asg-subnet-1"
  }
}
resource "aws_subnet" "asg_subnet_2" {
  vpc_id                  = aws_vpc.alb_vpc.id
  cidr_block             = "10.0.5.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-2b"
tags = {
    Name = "asg-subnet-2"
  }
}

/// ASG

resource "aws_launch_template" "service_2_asg_template" {
  name_prefix = "service-2-asg-template"
  image_id = "ami-09694bfab577e90b0" 
  instance_type = "t2.micro" 
  user_data = filebase64("${path.module}/webserver.sh")
  iam_instance_profile {
    arn = aws_iam_instance_profile.asg_profile.arn
  }
  vpc_security_group_ids = [aws_security_group.service_2_asg_sg.id]
  tags = {
    Name = "service-2-asg-template"
  }
}

resource "aws_autoscaling_group" "service_2_asg" {
  name = "service-2-asg"
  launch_template {
    id = aws_launch_template.service_2_asg_template.id
    version = "$Latest"
  }
  min_size = 2
  max_size = 4
  desired_capacity = 2
  vpc_zone_identifier = [aws_subnet.asg_subnet_1.id, aws_subnet.asg_subnet_2.id]
  target_group_arns = [aws_lb_target_group.service_2_asg_tg.arn]
  health_check_type = "ELB"

}

resource "aws_autoscaling_policy" "service_2_asg_policy" {
    name = "cpu-scaling-policy"
    policy_type = "TargetTrackingScaling" 
    adjustment_type = "ChangeInCapacity"
    # cooldown = 300
    metric_aggregation_type = "Average"


    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }

      target_value = 60.0
    }
  autoscaling_group_name = aws_autoscaling_group.service_2_asg.name
}

///// create ALB

resource "aws_lb" "service_2_alb" {
  name = "service-2-alb"
  internal = true
  load_balancer_type = "application"
  subnets = [aws_subnet.asg_subnet_1.id, aws_subnet.asg_subnet_2.id]
  security_groups = [aws_security_group.service_2_alb_sg.id]
}


resource "aws_lb_target_group" "service_2_asg_tg" {
  name = "web-server-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.alb_vpc.id
  target_type = "instance"

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 30
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.service_2_alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.service_2_asg_tg.arn
  }
}

resource "aws_iam_instance_profile" "asg_profile" {
  name = "asg-instance-profile"
  role = aws_iam_role.asg_role.name
}

resource "aws_iam_role" "asg_role" {
  name = "asg-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_security_group" "service_2_asg_sg" {
  name = "web-server-sg"
  vpc_id = aws_vpc.alb_vpc.id

  # Allow inbound HTTP traffic from the ALB
  ingress {
    description = "allow traffic from application load balancer"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.service_2_alb_sg.id]
  }

  # Allow outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "service_2_alb_sg" {
  name = "service-2-alb-sg"
  vpc_id = aws_vpc.alb_vpc.id
  # Allow inbound HTTP traffic from internal sources (if relevant)
  ingress {
    description = "allow web traffic from internal sources"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to the target group instances
#   egress {
#     from_port = 80
#     to_port = 80
#     protocol = "-1"
#     security_groups = [module.alb-target.service_2_asg_sg_id]
#   }
}

///



# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc.id
# }

# resource "aws_subnet" "public_subnet" {
#   count = 2
#   vpc_id = aws_vpc.vpc.id
#   cidr_block = cidrsubnet(var.cidr, 8, count.index + 1)

#   availability_zone = element(data.aws_availability_zones.available.names, count.index)

#   map_public_ip_on_launch = true
# }

# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
# }

# resource "aws_route_table_association" "public_subnet_association" {
#   count = 2
#   subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
#   route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_flow_log" "vpc_flow_log" {
#   iam_role_arn = aws_iam_role.flow_log_role.arn
#   log_destination = aws_cloudwatch_logs_log_group.flow_log_group.arn
#   traffic_type = "ALL"
#   vpc_id = aws_vpc.vpc.id
# }

# resource "aws_iam_role" "flow_log_role" {
#   name = "vpc_flow_log_role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "vpc-flow-logs.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_cloudwatch_logs_log_group" "flow_log_group" {
#   name = "vpc_flow_logs"
# }

# resource "aws_cloudwatch_logs_log_stream" "flow_log_stream" {
#   name = "vpc_flow_log_stream"
#   log_group_name = aws_cloudwatch_logs_log_group.flow_log_group.name
# }

# resource "aws_iam_role_policy" "flow_log_policy" {
#   name = "flow_log_policy"
#   role = aws_iam_role.flow_log_role.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#         "arn:aws:logs:*:*:log-group:vpc_flow_logs:*"
#       ]
#     }
#   ]
# }
# EOF
# }

output "vpc_id" {
  value = aws_vpc.alb_vpc.id
}
output "target_group_arns" {
  value = [aws_lb_target_group.service_2_asg_tg.arn]
}
output "service_2_asg_sg_id" {
  value = aws_security_group.service_2_asg_sg.id
}

output "service_2_alb_sg_id" {
  value = aws_security_group.service_2_alb_sg.id
}

# output "public_subnet_ids" {
#   value = aws_subnet.public_subnet.*.id
# }
