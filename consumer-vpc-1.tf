
resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
    tags = {
    Name = "vpc-1"
  }
}

resource "aws_subnet" "subnet1_vpc1" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "subnet2_vpc1" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc_1.id
}

// start of public subnet
resource "aws_subnet" "public_sn" {
  vpc_id = aws_vpc.vpc_1.id
  cidr_block = "10.0.0.0/24" 
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_1.id
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
  vpc_id = aws_vpc.vpc_1.id
}

// end of public subnet

resource "aws_route_table_association" "private_subnet1_vpc1" {
  subnet_id      = aws_subnet.subnet1_vpc1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet2_vpc1" {
  subnet_id      = aws_subnet.subnet2_vpc1.id
  route_table_id = aws_route_table.private.id
}


resource "aws_security_group" "lattice-client-sg" {
  name        = "allow_https"
  description = "Allow HTTPS outbound traffic"
  vpc_id      = aws_vpc.vpc_1.id

  egress {
    description = "Allow HTTPS outbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow HTTP outbound traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow Client Subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}


resource "aws_iam_role" "flow_log" {
  name = "flow-log-role"

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

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/vpc-1-flow-logs"
  retention_in_days = 30  # Adjust the retention period as needed
}

resource "aws_flow_log" "vpc_flow_logs" {
  depends_on              = [aws_vpc.vpc_1]
  iam_role_arn            = aws_iam_role.flow_log.arn
  log_destination_type    = "cloud-watch-logs"
  log_destination         = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type            = "ALL"
  vpc_id                  = aws_vpc.vpc_1.id
  # log_format              = "$${version}"
  max_aggregation_interval = 60

  tags = {
    Name = "vpc-1-flow-logs"
  }
}

output "lattice-client-sg" {
  description = "The ID of the security group"
  value       = aws_security_group.lattice-client-sg.id
}


output "vpc_1_id" {
    value = aws_vpc.vpc_1.id
}
output "aws_subnet_subnet1_vpc1_id" {
    value = aws_subnet.subnet1_vpc1.id
}
output "aws_subnet_subnet2_vpc1_id" {
    value = aws_subnet.subnet2_vpc1.id
}