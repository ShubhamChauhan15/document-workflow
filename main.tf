provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidr    = "10.0.1.0/24"
  private_subnet_cidr   = "10.0.2.0/24"
  az_1                  = "us-east-1a"
  az_2                  = "us-east-1b"
  ami_id                = "ami-xxxxxxxxxxxxxxxxx"  # Replace with your AMI ID
  instance_type         = "t3.micro"
  region                = "us-east-1"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "instance_id" {
  value = module.vpc.instance_id
}

output "instance_public_ip" {
  value = module.vpc.instance_public_ip
}
