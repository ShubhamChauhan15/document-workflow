output "private_sg_id" {
  description = "The ID of the private security group"
  value       = aws_security_group.private_sg.id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.epc_vpc.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}
