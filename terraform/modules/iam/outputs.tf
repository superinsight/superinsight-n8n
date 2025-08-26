output "ecs_task_execution_role_arn" {
  description = "ARN of ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "n8n_aws_access_policy_arn" {
  description = "ARN of n8n AWS access policy"
  value       = aws_iam_policy.n8n_aws_access.arn
}