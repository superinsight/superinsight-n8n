terraform {
  backend "s3" {
    bucket         = "superinsight-terraform-state-465636789521"
    key            = "n8n/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "superinsight-terraform-locks"
    encrypt        = true
  }
}