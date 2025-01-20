resource "aws_vpc" "epc_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "EPC_VPC"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.epc_vpc.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.private_subnet_az
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Security group for EC2 instance in private subnet"
  vpc_id      = aws_vpc.epc_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ec2_messages_endpoint" {
  vpc_id            = aws_vpc.epc_vpc.id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  private_dns_enabled = true
  security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "EC2 Messages VPC Endpoint"
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.epc_vpc.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"  # Ensure type is Interface for endpoint in a subnet
  subnet_ids        = [aws_subnet.private_subnet.id] # Specify the subnets for interface endpoint
  private_dns_enabled = true
  security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "SSM VPC Endpoint"
  }
}
resource "aws_vpc_endpoint" "ssm_messages_endpoint" {
  vpc_id            = aws_vpc.epc_vpc.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  private_dns_enabled = true
  security_group_ids = [aws_security_group.private_sg.id]
  tags = {
    Name = "SSM Messages VPC Endpoint"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.epc_vpc.id
  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

#resource "aws_networkmanager_global_network" "global_network" {
#  description = "Global Network for EPC VPC"
#  tags = {
#    Name = "EPC Global Network"
  }
}

#resource "aws_networkmanager_site" "site" {
#  global_network_id = aws_networkmanager_global_network.global_network.id
 # location {
 #  address = "VPC Location Address"
 # }
 #tags = {
 #   Name = "EPC Site"
 # }
# }
