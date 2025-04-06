data "aws_secretsmanager_secret" "dagster_secrets" {
  name = "${var.resource_prefix}-dagster-secrets"
}

data "aws_secretsmanager_secret_version" "dagster_secrets" {
  secret_id = data.aws_secretsmanager_secret.dagster_secrets.id
}