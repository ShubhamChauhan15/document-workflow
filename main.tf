terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 0.14.9"
}
provider "aws" {
  
  region  = "us-east-1"
}

module "VPC-MODULE" {
  source               = "./VPC_module"
  vpc_cidr_block       = "10.0.0.0/16"
  public_subnet_cidr   = "10.0.1.0/24"
  private_subnet_cidr  = "10.0.2.0/24"
  private_subnet_az    = "us-east-1a"
}

module "Instance_module" {
  source              = "./Instance_module"
  vpc_id              = module.VPC-MODULE.vpc_id
  private_subnet_id   = module.VPC-MODULE.private_subnet_id
  ami_id              = "ami-0df8c184d5f6ae949"
  instance_type       = "t2.micro"
  security_group_id   = module.VPC-MODULE.private_sg_id
}

