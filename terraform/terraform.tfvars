# ============================================================================
# Terraform Variables for n8n Production Environment
# ============================================================================

# General Configuration
aws_region  = "ap-northeast-1"
environment = "production"

# Network Configuration
vpc_cidr = "10.1.0.0/24"  # Compact CIDR for cost optimization

# Database Configuration
db_instance_class    = "db.t3.medium"
db_allocated_storage = 50
db_name             = "n8n_production"
db_username         = "n8n_admin"

# n8n Application Configuration
n8n_image        = "n8nio/n8n:latest"
n8n_cpu          = 2048
n8n_memory       = 4096
n8n_desired_count = 2

# Domain Configuration (optional - update if you have a domain)
# n8n_domain_name = "n8n.yourdomain.com"
# certificate_arn = "arn:aws:acm:ap-northeast-1:ACCOUNT_ID:certificate/CERT_ID"

# Security Configuration
# Note: These will be prompted for during terraform apply
# trustcloud_api_key = "your-trustcloud-api-key"
# n8n_encryption_key = "your-generated-encryption-key"

# Monitoring Configuration
enable_detailed_monitoring = true
log_retention_days         = 30

# Backup Configuration
backup_retention_period    = 7
enable_deletion_protection = true