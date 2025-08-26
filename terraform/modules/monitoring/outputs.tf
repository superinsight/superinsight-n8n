output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.n8n.dashboard_name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = "/ecs/${var.environment}-n8n"
}

output "sns_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = aws_sns_topic.alerts.arn
}