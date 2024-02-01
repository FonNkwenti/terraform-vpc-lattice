
# Create a security group for SSH access
resource "aws_security_group" "ssh_sg" {
  name        = "ssh_sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.vpc_1.id
  

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere (for testing purposes)
  }
}
resource "aws_security_group" "ping_sg" {
  name        = "ping security group"
  description = "Allow ICMP traffic"
  vpc_id      = aws_vpc.vpc_1.id

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ping_sg"
  }
}



resource "aws_instance" "ec2-client" {
  ami             = "ami-09694bfab577e90b0" 
  instance_type   = "t2.micro"  
  subnet_id       = aws_subnet.public_sn.id
  # subnet_id       = aws_subnet.subnet1_vpc1.id
#   subnet_id       = aws_subnet.subnet1_vpc2.id
  vpc_security_group_ids = [aws_security_group.lattice-client-sg.id, aws_security_group.ping_sg.id]
  key_name        = "default-ue2"  
  iam_instance_profile = aws_iam_instance_profile.lattice_ec2_client_profile.name
  user_data_replace_on_change = true
  user_data_base64 = "IyEvYmluL2Jhc2gNCnN1ZG8geXVtIHVwZGF0ZSAteQ0Kc3VkbyB5dW0gaW5zdGFsbCAteSBodHRwZA0Kc3VkbyBzeXN0ZW1jdGwgc3RhcnQgaHR0cGQNCnN1ZG8gc3lzdGVtY3RsIGVuYWJsZSBodHRwZA0Kc3VkbyB1c2VybW9kIC1hIC1HIGFwYWNoZSBlYzItdXNlcg0Kc3VkbyBjaG93biAtUiBlYzItdXNlcjphcGFjaGUgL3Zhci93d3cNCnN1ZG8gY2htb2QgMjc3NSAvdmFyL3d3dw0Kc3VkbyBmaW5kIC92YXIvd3d3IC10eXBlIGQgLWV4ZWMgY2htb2QgMjc3NSB7fSBcOw0Kc3VkbyBmaW5kIC92YXIvd3d3IC10eXBlIGYgLWV4ZWMgY2htb2QgMDY2NCB7fSBcOw0Kc3VkbyBlY2hvICI8P3BocCBwaHBpbmZvKCk7ID8+IiA+IC92YXIvd3d3L2h0bWwvcGhwaW5mby5waHA="

  tags = {
    Name = "ec2-client"
  }
}

output "instance_private_ip" {
  value = aws_instance.ec2-client.private_ip
}
output "instance_public_ip" {
  value = aws_instance.ec2-client.public_ip
}
