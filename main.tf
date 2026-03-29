# ==============================================================================
#  MAIN.TF — S3 Bucket + Proof Artifacts for Class 7 Lab
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

# ── S3 BUCKET ────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "jenkins_test" {
  bucket = "aarmour031726"

  tags = {
    Name        = "Jenkins Pipeline Test"
    Environment = "lab"
    ManagedBy   = "terraform"
    Class       = "aws-class-7"
  }
}

# ── MAKE BUCKET PUBLIC ───────────────────────────────────────────────────────

# Disable the default "Block All Public Access" setting
resource "aws_s3_bucket_public_access_block" "jenkins_test_public" {
  bucket = aws_s3_bucket.jenkins_test.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy granting public read to all objects
resource "aws_s3_bucket_policy" "jenkins_test_policy" {
  bucket = aws_s3_bucket.jenkins_test.id

  # Must wait for the public access block to be disabled first
  depends_on = [aws_s3_bucket_public_access_block.jenkins_test_public]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.jenkins_test.arn}/*"
      }
    ]
  })
}

# ── PROOF ARTIFACTS ──────────────────────────────────────────────────────────

resource "aws_s3_object" "theo_confirmation" {
  bucket       = aws_s3_bucket.jenkins_test.id
  key          = "proof/theo_confirmation.png"
  source       = "${path.module}/proof/theo_confirmation.png"
  content_type = "image/png"
  etag         = filemd5("${path.module}/proof/theo_confirmation.png")
}

resource "aws_s3_object" "armageddon_repo" {
  bucket       = aws_s3_bucket.jenkins_test.id
  key          = "proof/armageddon_repo.md"
  source       = "${path.module}/proof/armageddon_repo.md"
  content_type = "text/markdown"
  etag         = filemd5("${path.module}/proof/armageddon_repo.md")
}

# ── VALIDATION SCREENSHOTS ───────────────────────────────────────────────────

resource "aws_s3_object" "jenkins_success" {
  bucket       = aws_s3_bucket.jenkins_test.id
  key          = "proof/jenkins_success.png"
  source       = "${path.module}/proof/jenkins_success.png"
  content_type = "image/png"
  etag         = filemd5("${path.module}/proof/jenkins_success.png")
}

resource "aws_s3_object" "s3_bucket_contents" {
  bucket       = aws_s3_bucket.jenkins_test.id
  key          = "proof/s3_bucket_contents.png"
  source       = "${path.module}/proof/s3_bucket_contents.png"
  content_type = "image/png"
  etag         = filemd5("${path.module}/proof/s3_bucket_contents.png")
}

resource "aws_s3_object" "webhook_delivery" {
  bucket       = aws_s3_bucket.jenkins_test.id
  key          = "proof/webhook_delivery.png"
  source       = "${path.module}/proof/webhook_delivery.png"
  content_type = "image/png"
  etag         = filemd5("${path.module}/proof/webhook_delivery.png")
}