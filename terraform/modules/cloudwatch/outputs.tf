output "log_group_name" {
  description = "Name of the CloudWatch log group for Dagster logs"
  value       = aws_cloudwatch_log_group.dagster_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for Dagster logs"
  value       = aws_cloudwatch_log_group.dagster_logs.arn
}