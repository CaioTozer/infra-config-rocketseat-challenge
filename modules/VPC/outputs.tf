
output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.this.id
}

output "subnet_id" {
  description = "ID da subnet"
  value       = aws_subnet.this.id
}

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = aws_internet_gateway.this.id
}
