# Backend configuration for Terraform state
terraform {
  backend "s3" {
    bucket         = "superinsight-terraform-state-prod"
    key            = "n8n/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "superinsight-terraform-locks"
    encrypt        = true
  }
}
