
resource "aws_vpc" "vpc_2" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-2"
  }
}

resource "aws_subnet" "subnet1_vpc2" {
  vpc_id     = aws_vpc.vpc_2.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.1.0/24"
}

// start of public subnet
resource "aws_subnet" "public_sn" {
  vpc_id = aws_vpc.vpc_2.id
  cidr_block = "10.0.0.0/24" 
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_2.id
}

resource "aws_route" "public_route" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id 

}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public_sn.id
  route_table_id = aws_route_table.public_rt.id
  
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_2.id
}

// end of public subnet


resource "aws_route_table" "private_vpc2" {
  vpc_id = aws_vpc.vpc_2.id
}

resource "aws_route_table_association" "private_subnet1_vpc2" {
  subnet_id      = aws_subnet.subnet1_vpc2.id
  route_table_id = aws_route_table.private_vpc2.id
}



resource "aws_security_group" "egress_https_vpc2" {
  name        = "allow_https"
  description = "Allow HTTPS outbound traffic"
  vpc_id      = aws_vpc.vpc_2.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "egress_http_vpc2" {
  name        = "allow_http"
  description = "Allow HTTP outbound traffic"
  vpc_id      = aws_vpc.vpc_2.id

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_iam_role" "flow_log_vpc2" {
  name = "flow-log-role-vpc2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_cloudwatch_log_group" "flow_logs_vpc2" {
  name              = "/aws/vpc/flow-logs_vpc2"
  retention_in_days = 30  # Adjust the retention period as needed
}

resource "aws_flow_log" "vpc_flow_logs_vpc2" {
  depends_on              = [aws_vpc.vpc_2]
  iam_role_arn            = aws_iam_role.flow_log.arn
  log_destination_type    = "cloud-watch-logs"
  log_destination         = aws_cloudwatch_log_group.flow_logs_vpc2.arn
  traffic_type            = "ALL"
  vpc_id                  = aws_vpc.vpc_2.id
  max_aggregation_interval = 60

  tags = {
    Name = "flow-logs-vpc2"
  }
}

output "egress_https_sg_vpc2_id" {
  description = "The ID of the security group"
  value       = aws_security_group.egress_https_vpc2.id
}

output "egress_http_sg_vpc2_id" {
  description = "The ID of the security group"
  value       = aws_security_group.egress_http_vpc2.id
}

output "vpc_2_id" {
    value = aws_vpc.vpc_2.id
}

output "aws_subnet_subnet1_vpc_2_id" {
    value = aws_subnet.subnet1_vpc2.id
}
