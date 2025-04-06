resource "aws_s3_bucket" "dagster_storage" {
  bucket = "${var.resource_prefix}-dagster-storage"
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.dagster_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}