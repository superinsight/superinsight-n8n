output "workflow_bucket_name" {
  description = "Name of the workflow S3 bucket"
  value       = aws_s3_bucket.workflows.bucket
}

output "backup_bucket_name" {
  description = "Name of the backup S3 bucket"
  value       = aws_s3_bucket.backup.bucket
}

output "workflow_bucket_arn" {
  description = "ARN of the workflow S3 bucket"
  value       = aws_s3_bucket.workflows.arn
}

output "backup_bucket_arn" {
  description = "ARN of the backup S3 bucket"
  value       = aws_s3_bucket.backup.arn
}