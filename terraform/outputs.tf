# ============================================================================
# Outputs for n8n Infrastructure
# ============================================================================

# ============================================================================
# Network Outputs
# ============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# ============================================================================
# Database Outputs
# ============================================================================

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "database_name" {
  description = "Database name"
  value       = var.db_name
}

# ============================================================================
# n8n Application Outputs
# ============================================================================

output "n8n_url" {
  description = "n8n application URL"
  value       = module.ecs.n8n_url
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.ecs.alb_dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.ecs_service_name
}

# ============================================================================
# Storage Outputs
# ============================================================================

output "s3_workflow_bucket" {
  description = "S3 bucket for n8n workflows"
  value       = module.storage.workflow_bucket_name
}

output "s3_backup_bucket" {
  description = "S3 bucket for backups"
  value       = module.storage.backup_bucket_name
}

# ============================================================================
# Security Outputs
# ============================================================================

output "secrets_manager_arns" {
  description = "ARNs of secrets in Secrets Manager"
  value       = module.secrets.secret_arns
  sensitive   = true
}

# ============================================================================
# Monitoring Outputs
# ============================================================================

output "cloudwatch_log_group" {
  description = "CloudWatch log group for n8n"
  value       = module.monitoring.log_group_name
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.monitoring.dashboard_name}"
}

# ============================================================================
# Cost Information
# ============================================================================

output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (USD)"
  value = {
    ecs_fargate     = "~$120-200 (2 tasks, 2 vCPU, 4GB each)"
    rds_postgres    = "~$60-90 (db.t3.medium)"
    alb            = "~$20"
    s3_storage     = "~$10-30"
    cloudwatch     = "~$10-20"
    secrets_manager = "~$2"
    data_transfer  = "~$20-50"
    total_estimate = "~$240-410/month"
  }
}

# ============================================================================
# Setup Instructions
# ============================================================================

output "setup_instructions" {
  description = "Next steps to complete the setup"
  value = {
    step_1 = "Access n8n at: ${module.ecs.n8n_url}"
    step_2 = "Initial setup wizard will prompt for admin credentials"
    step_3 = "Configure environment variables via ECS console if needed"
    step_4 = "Import n8n workflows from ../n8n-workflows/ directory"
    step_5 = "Set up TrustCloud credentials in n8n"
    step_6 = "Test AWS connectivity with provided IAM roles"
  }
}