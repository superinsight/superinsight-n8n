# ============================================================================
# Variables for n8n Infrastructure
# ============================================================================

# ============================================================================
# General Configuration
# ============================================================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

# ============================================================================
# Network Configuration
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ============================================================================
# Database Configuration
# ============================================================================

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 50
}

variable "db_name" {
  description = "Database name for n8n"
  type        = string
  default     = "n8n"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "n8n_admin"
}

# ============================================================================
# n8n Application Configuration
# ============================================================================

variable "n8n_image" {
  description = "n8n Docker image"
  type        = string
  default     = "n8nio/n8n:latest"
}

variable "n8n_cpu" {
  description = "n8n ECS task CPU units"
  type        = number
  default     = 2048
}

variable "n8n_memory" {
  description = "n8n ECS task memory in MB"
  type        = number
  default     = 4096
}

variable "n8n_desired_count" {
  description = "Desired number of n8n tasks"
  type        = number
  default     = 2
}

variable "n8n_domain_name" {
  description = "Domain name for n8n (optional)"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "SSL certificate ARN for HTTPS (optional)"
  type        = string
  default     = ""
}

# ============================================================================
# Security Configuration
# ============================================================================

variable "trustcloud_api_key" {
  description = "TrustCloud API Key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "n8n_encryption_key" {
  description = "n8n encryption key for sensitive data"
  type        = string
  sensitive   = true
  default     = ""
}

# ============================================================================
# Monitoring Configuration
# ============================================================================

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch logs retention period"
  type        = number
  default     = 30
}

# ============================================================================
# Backup Configuration
# ============================================================================

variable "backup_retention_period" {
  description = "Database backup retention period in days"
  type        = number
  default     = 7
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = true
}