output "db_password" {
  description = "Database password retrieved from Secrets Manager"
  value       = jsondecode(data.aws_secretsmanager_secret_version.dagster_secrets.secret_string)["db_password"]
  sensitive   = true
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = data.aws_secretsmanager_secret.dagster_secrets.arn
}