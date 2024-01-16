output "region" {
    value = "us-east-1"
}   

output "project_name" {
    value = "terraform-vpc-lattice"
}   

output "vpc_id" {
    value = [module.vpc_1.aws_vpc.main.id, module.vpc_2.aws_vpc.main.id]
}

output "private_subnet_az1_id" {
    value = [module.vpc_1.aws_subnet.private_subnet_az1.id, module.vpc_2.aws_subnet.private_subnet_az1.id]
}

output "private_subnet_az2_id" {
    value = [module.vpc_1.aws_subnet.private_subnet_az2.id, module.vpc_2.aws_subnet.private_subnet_az2.id]
}

################

