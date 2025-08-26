output "secret_arns" {
  description = "ARNs of all secrets"
  value = {
    database_credentials = aws_secretsmanager_secret.db_credentials.arn
    trustcloud_api_key   = aws_secretsmanager_secret.trustcloud_api_key.arn
    n8n_encryption_key   = aws_secretsmanager_secret.n8n_encryption_key.arn
  }
  sensitive = true
}