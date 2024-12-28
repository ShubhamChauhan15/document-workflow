variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "az_1" {
  description = "The availability zone for the public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "az_2" {
  description = "The availability zone for the private subnet"
  type        = string
  default     = "us-east-1b"
}


