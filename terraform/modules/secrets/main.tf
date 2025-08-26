# ============================================================================
# Secrets Manager Module
# ============================================================================

# Database credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "n8n/${var.environment}/database-credentials"
  description             = "n8n database credentials"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-database-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    password = var.db_password
  })
}

# TrustCloud API Key
resource "aws_secretsmanager_secret" "trustcloud_api_key" {
  name                    = "n8n/${var.environment}/trustcloud-api-key"
  description             = "TrustCloud API key for compliance integration"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-trustcloud-api-key"
  })
}

resource "aws_secretsmanager_secret_version" "trustcloud_api_key" {
  secret_id = aws_secretsmanager_secret.trustcloud_api_key.id
  secret_string = jsonencode({
    api_key = var.trustcloud_api_key
  })
}

# n8n encryption key
resource "aws_secretsmanager_secret" "n8n_encryption_key" {
  name                    = "n8n/${var.environment}/encryption-key"
  description             = "n8n encryption key for sensitive workflow data"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.environment}-n8n-encryption-key"
  })
}

resource "aws_secretsmanager_secret_version" "n8n_encryption_key" {
  secret_id = aws_secretsmanager_secret.n8n_encryption_key.id
  secret_string = jsonencode({
    encryption_key = var.n8n_encryption_key
  })
}