# ==============================================================================
#  MAIN.TF — S3 Bucket + Proof Artifacts for Class 7 Lab
# ==============================================================================
#  Purpose:  Creates S3 bucket and uploads proof-of-completion artifacts
#            via Jenkins webhook-triggered pipeline.
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
  region = "us-west-2"
}

resource "aws_s3_bucket" "jenkins_test" {
  bucket = "aarmour031726"

  tags = {
    Name        = "Jenkins Pipeline Test"
    Environment = "lab"
    ManagedBy   = "terraform"
    Class       = "aws-class-7"
  }
}

# Upload Theo's confirmation screenshot
resource "aws_s3_object" "theo_confirmation" {
  bucket       = aws_s3_bucket.jenkins_test.id
  key          = "proof/theo_confirmation.png"
  source       = "${path.module}/proof/theo_confirmation.png"
  content_type = "image/png"
}

# Upload Armageddon repo link
resource "aws_s3_object" "armageddon_repo" {
  bucket       = aws_s3_bucket.jenkins_test.id
  key          = "proof/armageddon_repo.md"
  source       = "${path.module}/proof/armageddon_repo.md"
  content_type = "text/markdown"
}