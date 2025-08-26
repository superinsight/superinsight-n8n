variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "trustcloud_api_key" {
  description = "TrustCloud API key"
  type        = string
  sensitive   = true
}

variable "n8n_encryption_key" {
  description = "n8n encryption key"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}