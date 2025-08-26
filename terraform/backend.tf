terraform {
  backend "s3" {
    bucket         = "superinsight-terraform-state-465636789521-oregon"
    key            = "n8n/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "superinsight-terraform-locks-oregon"
    encrypt        = true
  }
}