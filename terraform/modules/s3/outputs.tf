output "bucket_name" {
  description = "Name of the S3 bucket used for Dagster storage"
  value       = aws_s3_bucket.dagster_storage.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket used for Dagster storage"
  value       = aws_s3_bucket.dagster_storage.arn
}