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
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
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

# Network Manager Global Network Configuration
resource "aws_networkmanager_global_network" "global_network" {
  description = "Global Network for EPC VPC"
  tags = {
    Name = "EPC Global Network"
  }
}


resource "aws_networkmanager_site" "site" {
  global_network_id = aws_networkmanager_global_network.global_network.id
  location {
    address = "VPC Location Address"
  }
  tags = {
    Name = "EPC Site"
  }
}


resource "aws_ec2_transit_gateway" "tgw" {
  description = "EPC Transit Gateway"
  amazon_side_asn = 64512 # Optional, define the ASN for the TGW
  tags = {
    Name = "EPC Transit Gateway"
  }
}

# Create Transit Gateway Attachment to VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.epc_vpc.id
  subnet_ids         = [aws_subnet.private_subnet.id]

  tags = {
    Name = "VPC Attachment to Transit Gateway"
  }
}


resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_route_propagation" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
}


resource "aws_networkmanager_transit_gateway_registration" "tgw_registration" {
  global_network_id = aws_networkmanager_global_network.global_network.id
  transit_gateway_arn = aws_ec2_transit_gateway.tgw.arn
  
}

resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "EPC Transit Gateway Route Table"
  }
}
