
resource "aws_vpc" "vpc_2" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-2"
  }
}

resource "aws_subnet" "subnet1_vpc2" {
  vpc_id     = aws_vpc.vpc_2.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "subnet2_vpc2" {
  vpc_id     = aws_vpc.vpc_2.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_route_table" "private_vpc2" {
  vpc_id = aws_vpc.vpc_2.id
}

resource "aws_route_table_association" "private_subnet1_vpc2" {
  subnet_id      = aws_subnet.subnet1_vpc2.id
  route_table_id = aws_route_table.private_vpc2.id
}

resource "aws_route_table_association" "private_subnet2_vpc2" {
  subnet_id      = aws_subnet.subnet2_vpc2.id
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
output "aws_subnet_subnet2_vpc_2_id" {
    value = aws_subnet.subnet2_vpc2.id
}