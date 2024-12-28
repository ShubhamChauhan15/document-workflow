resource "aws_iam_role" "ssm_role" {
  name               = "ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_role_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "private_instance" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.private_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = false
  tags = {
    Name = "PrivateInstance"
  }
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "private_sg" {
  name_prefix = "private-instance-sg-"
  description = "Allow all traffic from within the VPC"

  vpc_id = aws_vpc.main.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    cidr_blocks = ["10.0.0.0/8"] # Allow communication within the VPC (adjust if needed)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.private_sg.id]
  subnet_ids         = [aws_subnet.private.id]
}

output "instance_id" {
  value = aws_instance.private_instance.id
}

output "instance_public_ip" {
  value = aws_instance.private_instance.public_ip
}
