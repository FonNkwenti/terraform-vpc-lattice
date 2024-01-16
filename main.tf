# create vpc from vpc module
module "vpc_1" {
    source                  = "./modules/vpc"
    project_name            = var.project_name
    region                  = "us-east-1"
    vpc_name                = "vpc-1"
    vpc_cidr                = "10.0.0.0/16"
    az1                     = "us-east-1a"
    az2                     = "us-east-1b"
    private_subnet_az1_cidr = "10.0.1.0/24"
    private_subnet_az2_cidr = "10.0.2.0/24"
}
# create vpc from vpc module
module "vpc_2" {
    source                  = "./modules/vpc"
    project_name            = var.project_name
    region                  = "us-east-1"
    vpc_name                = "vpc-2"
    vpc_cidr                = "10.0.0.0/16"
    az1                     = "us-east-1a"
    az2                     = "us-east-1b"
    private_subnet_az1_cidr = "10.0.1.0/24"
    private_subnet_az2_cidr = "10.0.2.0/24"
}
