output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.n8n.name
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn_suffix" {
  description = "ARN suffix of the load balancer"
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "n8n_url" {
  description = "URL to access n8n"
  value       = var.certificate_arn != "" ? "https://${var.n8n_domain_name != "" ? var.n8n_domain_name : aws_lb.main.dns_name}" : "http://${aws_lb.main.dns_name}"
}