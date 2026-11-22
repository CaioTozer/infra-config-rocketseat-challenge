
output "load_balancer_arn" {
  description = "ARN do Application Load Balancer"
  value       = aws_lb.this.arn
}

output "load_balancer_dns" {
  description = "DNS público do Load Balancer"
  value       = aws_lb.this.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID do Load Balancer"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN do Target Group"
  value       = aws_lb_target_group.this.arn
}

output "listener_arn" {
  description = "ARN do Listener HTTP"
  value       = aws_lb_listener.http.arn
}
