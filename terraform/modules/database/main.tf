# ============================================================================
# RDS Database Module
# ============================================================================

# Generate random password for database
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-n8n-db-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-db-subnet-group"
  })
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  family = "postgres15"
  name   = "${var.environment}-n8n-db-params"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-db-params"
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.environment}-n8n-database"

  # Engine
  engine         = "postgres"
  engine_version = "15.7"
  instance_class = var.db_instance_class

  # Storage
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 2
  storage_type         = "gp2"
  storage_encrypted    = true

  # Database
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false
  port                   = 5432
  multi_az              = false  # Single AZ for cost optimization

  # Backup
  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "Sun:04:00-Sun:05:00"
  
  # Monitoring
  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn        = aws_iam_role.rds_monitoring.arn

  # Security
  deletion_protection = var.enable_deletion_protection
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.environment}-n8n-db-final-snapshot"

  # Parameters
  parameter_group_name = aws_db_parameter_group.main.name

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-database"
  })

  depends_on = [
    aws_db_subnet_group.main,
    aws_db_parameter_group.main,
    aws_iam_role.rds_monitoring
  ]
}

# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.environment}-n8n-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-rds-monitoring-role"
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Log Group for database logs
resource "aws_cloudwatch_log_group" "database" {
  name              = "/aws/rds/instance/${aws_db_instance.main.identifier}/postgresql"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-database-logs"
  })
}