output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN da instância EC2"
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Endereço IP privado da instância"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Endereço IP público da instância"
  value       = aws_instance.this.public_ip
}