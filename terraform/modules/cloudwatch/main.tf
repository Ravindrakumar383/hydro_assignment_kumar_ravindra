resource "aws_cloudwatch_log_group" "dagster_logs" {
  name              = "/dagster/${var.resource_prefix}"
  retention_in_days = var.log_retention_days
}