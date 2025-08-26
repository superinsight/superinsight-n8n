# ============================================================================
# n8n AWS Infrastructure - Main Configuration
# ============================================================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "n8n-hipaa-compliance"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "superinsight"
    }
  }
}

# ============================================================================
# Data Sources
# ============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ============================================================================
# VPC and Networking
# ============================================================================

module "vpc" {
  source = "./modules/networking"

  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  environment        = var.environment

  tags = local.common_tags
}

# ============================================================================
# Security Groups
# ============================================================================

module "security_groups" {
  source = "./modules/security"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment

  tags = local.common_tags
}

# ============================================================================
# RDS Database
# ============================================================================

module "database" {
  source = "./modules/database"

  vpc_id              = module.vpc.vpc_id
  database_subnet_ids = module.vpc.database_subnet_ids
  security_group_id   = module.security_groups.rds_security_group_id

  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username

  environment = var.environment

  tags = local.common_tags
}

# ============================================================================
# ECS Cluster and Service
# ============================================================================

module "ecs" {
  source = "./modules/ecs"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  ecs_security_group_id = module.security_groups.ecs_security_group_id
  alb_security_group_id = module.security_groups.alb_security_group_id

  # IAM Roles
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn

  # Database connection
  db_host     = module.database.db_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  db_password = module.database.db_password

  # n8n configuration
  n8n_image         = var.n8n_image
  n8n_cpu           = var.n8n_cpu
  n8n_memory        = var.n8n_memory
  n8n_desired_count = var.n8n_desired_count
  n8n_domain_name   = var.n8n_domain_name
  certificate_arn   = var.certificate_arn

  environment = var.environment

  tags = local.common_tags
}

# ============================================================================
# S3 Buckets
# ============================================================================

module "storage" {
  source = "./modules/storage"

  environment = var.environment

  tags = local.common_tags
}

# ============================================================================
# Secrets Manager
# ============================================================================

module "secrets" {
  source = "./modules/secrets"

  db_password        = module.database.db_password
  trustcloud_api_key = var.trustcloud_api_key
  n8n_encryption_key = var.n8n_encryption_key

  environment = var.environment

  tags = local.common_tags
}

# ============================================================================
# CloudWatch and Monitoring
# ============================================================================

module "monitoring" {
  source = "./modules/monitoring"

  ecs_cluster_name = module.ecs.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
  rds_instance_id  = module.database.db_instance_id
  alb_arn_suffix   = module.ecs.alb_arn_suffix

  environment = var.environment

  tags = local.common_tags
}

# ============================================================================
# IAM Roles and Policies
# ============================================================================

module "iam" {
  source = "./modules/iam"

  environment = var.environment

  tags = local.common_tags
}

# ============================================================================
# Local Values
# ============================================================================

locals {
  common_tags = {
    Project     = "n8n-hipaa-compliance"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "superinsight"
  }
}