# ==============================================================================
#  MAIN.TF — Simple S3 Bucket for Jenkins Pipeline Test
# ==============================================================================
#  Purpose:  Minimal Terraform config to verify your Jenkins pipeline works.
#            Creates a single S3 bucket — cheap, fast, easy to confirm.
#
#  Customize:
#    1. region → Your AWS region
#    2. bucket → Must be globally unique across all AWS accounts
# ==============================================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"   # Change to your region
}

resource "aws_s3_bucket" "jenkins_test" {
  bucket = "aarmour031726"   # Change to something globally unique

  tags = {
    Name        = "Jenkins Pipeline Test"
    Environment = "lab"
    ManagedBy   = "terraform"
    Class       = "aws-class-7"
  }
}
