terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}
provider "aws" {
  
  region  = "ap-south-1"
}

module "VPC-MODULE" {
  source               = "./VPC_module"
  vpc_cidr_block       = "10.0.0.0/16"
  public_subnet_cidr   = "10.0.1.0/24"
  private_subnet_cidr  = "10.0.2.0/24"
  public_subnet_az     = "ap-south-1a"
  private_subnet_az    = "ap-south-1b"
}

module "Instance_module" {
  source              = "./Instance_module"
  vpc_id              = module.vpc.vpc_id
  private_subnet_id   = module.vpc.private_subnet_id
  ami_id              = "ami-0fd05997b4dff7aac"  
  instance_type       = "t2.micro"
  security_group_id   = module.vpc.private_sg_id
}

